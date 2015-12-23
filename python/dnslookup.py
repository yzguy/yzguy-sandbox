#!venv/bin/python
#
# Dependencies: dnspython (http://www.dnspython.org/)
# pip install dnspython

import dns.resolver, dns.reversename, sys, argparse

parser = argparse.ArgumentParser()
parser.add_argument('-q', '--query', help='Query Name (A/CNAME: FQDN, NS/MX: Domain Name, PTR: IP Address)')
parser.add_argument('-t', '--type', help='Query Type (A, MX, NS, CNAME, PTR)')
parser.add_argument('-e', '--expect', help='Expected Answer (A/CNAME: IP Address, PTR/CNAME/MX/NS: FQDN)')
parser.add_argument('-n', '--nameserver', help='IP Address of Nameserver to perform lookup against')
args = parser.parse_args()

qname = args.query
rdtype = args.type
expans = args.expect
nameserver = args.nameserver

if (rdtype == 'PTR'):
    qname = dns.reversename.from_address(qname)
    expans = expans + "."
elif (rdtype == 'MX' or rdtype == 'CNAME' or rdtype == 'NS'):
    expans = expans + "."

try:
    resolver = dns.resolver.Resolver()
    resolver.lifetime = 3.0
    resolver.nameservers = [nameserver]
    resp = resolver.query(qname, rdtype)
    resplen = len(resp)

    def passed():
        print "PASS: ", resp.rrset.to_text()
        sys.exit(0)

    def failed():
        print "FAIL: ", resp.rrset.to_text()
        sys.exit(1)

    if (resplen > 1):
        for line in resp:
            ans = line.to_text()[(len(expans)*-1):]
            if (ans == expans):
                passed()
            elif (ans != expans):
                if (resplen > 1):
                    resplen -= 1
                    pass
                else:
                    failed()
            else:
                failed()
    else:
        if (resp.rrset.to_text()[(len(expans)*-1):] == expans):
            passed()
        else:
            failed()
except dns.resolver.NXDOMAIN:
    print "FAIL: %s does not exist" % qname
    sys.exit(1)
except dns.resolver.Timeout:
    print "FAIL: Timeout reached"
    sys.exit(1)
except dns.resolver.NoAnswer:
    print "FAIL: No Answer"
    sys.exit(1)
except dns.exception.DNSException:
    print "Unknown error"
    sys.exit(1)

