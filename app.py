#!/usr/bin/env python3

import bottle
from bottle import get, post, static_file, request, route, template
from bottle import SimpleTemplate
from configparser import ConfigParser
from ldap3 import Connection, Server
from ldap3 import SIMPLE, SUBTREE, MODIFY_REPLACE
from ldap3.core.exceptions import LDAPBindError, LDAPConstraintViolationResult, \
    LDAPInvalidCredentialsResult, LDAPUserNameIsMandatoryError, \
    LDAPSocketOpenError, LDAPExceptionError
import logging
import os
from os import environ, path
from Crypto.PublicKey import RSA


BASE_DIR = path.dirname(__file__)
LOG = logging.getLogger(__name__)
LOG_FORMAT = '%(asctime)s %(levelname)s: %(message)s'
VERSION = '2.0.1'


@get('/')
def get_index():
    return index_tpl()


@post('/')
def post_index():
    form = request.forms.getunicode

    def error(msg):
        return index_tpl(username=form('username'), alerts=[('error', msg)])

    try:
        key = RSA.importKey(form('ssh-prikey'), passphrase=form('passphrase'))
        ssh_pubkey = key.publickey().export_key('OpenSSH')
    except ValueError as e:
        LOG.error("Unable to decrypt private key for %s: %s" % (form('username'), e))
        return error(str("Unable to decrypt private key"))

    try:
        change_ssh_pubkey(form('username'), form('password'), ssh_pubkey)
    except Error as e:
        LOG.warning("Unsuccessful attempt to change SSH public key for %s: %s" % (form('username'), e))
        return error(str(e))

    LOG.info("SSH public key successfully changed for: %s" % form('username'))

    return index_tpl(alerts=[('success', "SSH public key has been changed")])


@route('/static/<filename>', name='static')
def serve_static(filename):
    return static_file(filename, root=path.join(BASE_DIR, 'static'))


def index_tpl(**kwargs):
    return template('index', **kwargs)


def connect_ldap(**kwargs):
    server = Server(host=CONF['ldap']['host'],
                    port=CONF['ldap'].getint('port', None),
                    use_ssl=CONF['ldap'].getboolean('use_ssl', False),
                    connect_timeout=5)

    return Connection(server, raise_exceptions=True, **kwargs)


def change_ssh_pubkey(*args):
    try:
        if CONF['ldap'].get('type') == 'ad':
            change_ssh_pubkey_ad(*args)
        else:
            change_ssh_pubkey_ldap(*args)

    except (LDAPBindError, LDAPInvalidCredentialsResult, LDAPUserNameIsMandatoryError):
        raise Error('Username or password is incorrect!')

    except LDAPConstraintViolationResult as e:
        # Extract useful part of the error message (for Samba 4 / AD).
        msg = e.message.split('check_password_restrictions: ')[-1].capitalize()
        raise Error(msg)

    except LDAPSocketOpenError as e:
        LOG.error('{}: {!s}'.format(e.__class__.__name__, e))
        raise Error('Unable to connect to the remote server.')

    except LDAPExceptionError as e:
        LOG.error('{}: {!s}'.format(e.__class__.__name__, e))
        raise Error('Encountered an unexpected error while communicating with the remote server.')


def change_ssh_pubkey_ldap(username, passwd, pubkey):
    with connect_ldap() as c:
        user_dn = find_user_dn(c, username)

    # Note: raises LDAPUserNameIsMandatoryError when user_dn is None.
    with connect_ldap(authentication=SIMPLE, user=user_dn, password=passwd) as c:
        c.bind()
        print("Not implemented yet")


def change_ssh_pubkey_ad(username, passwd, pubkey):
    user = username + '@' + CONF['ldap']['ad_domain']
    root = CONF['ldap']['user'] + '@' + CONF['ldap']['ad_domain']
    pubkey = ' '.join(pubkey.decode().split()[:2] + [username])

    # Bind as the requesting user to fetch user_dn
    with connect_ldap(authentication=SIMPLE, user=user, password=passwd) as c:
        c.bind()
        user_dn = find_user_dn(c, username)

    # Use a privileged account to update the attribute
    with connect_ldap(authentication=SIMPLE, user=root, password=CONF['ldap']['pass']) as c:
        c.bind()
        c.modify(user_dn, {'altSecurityIdentities': [(MODIFY_REPLACE, pubkey)]})


def find_user_dn(conn, uid):
    search_filter = CONF['ldap']['search_filter'].replace('{uid}', uid)
    conn.search(CONF['ldap']['base'], "(%s)" % search_filter, SUBTREE)

    return conn.response[0]['dn'] if conn.response else None


def read_config():
    config = ConfigParser()
    config.read([path.join(BASE_DIR, 'settings.ini'), os.getenv('CONF_FILE', '')])

    return config


class Error(Exception):
    pass


if environ.get('DEBUG'):
    bottle.debug(True)

# Set up logging.
logging.basicConfig(format=LOG_FORMAT)
LOG.setLevel(logging.INFO)
LOG.info("Starting ldap-ssh-key-webui %s" % VERSION)

CONF = read_config()

bottle.TEMPLATE_PATH = [BASE_DIR]

# Set default attributes to pass into templates.
SimpleTemplate.defaults = dict(CONF['html'])
SimpleTemplate.defaults['url'] = bottle.url


# Run bottle internal server when invoked directly (mainly for development).
if __name__ == '__main__':
    bottle.run(**CONF['server'])
# Run bottle in application mode (in production under uWSGI server).
else:
    application = bottle.default_app()
