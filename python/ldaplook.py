#!/usr/bin/python

import sys, ldap, base64

Server = "ldap://ldap.yzguy.io"
Username = "cn=admin,dc=yzguy,dc=io"
Password = base64.b64decode("")

try:
    l = ldap.initialize(Server)
    l.simple_bind_s(Username, Password)
except ldap.LDAPError, e:
    print e

baseDN = "dc=yzguy,dc=io"
searchScope = ldap.SCOPE_SUBTREE
retrieveAttributes = ['uid','loginShell']
searchFilter = "cn=*smithaj*"

ldap_result_id = l.search(baseDN, searchScope, searchFilter, retrieveAttributes)
result_set = []
while True:
    result_type, result_data = l.result(ldap_result_id, 0)
    if (result_data == []):
        break
    else:
        if result_type == ldap.RES_SEARCH_ENTRY:
            result_set.append(result_data)

    for i in range(len(result_set)):
        for entry in result_set[i]:
            try:
                uid = entry[1]['uid'][0]
                loginShell = entry[1]['loginShell'][0]
                print uid, loginShell
            except ldap.LDAPError, e:
                print e
