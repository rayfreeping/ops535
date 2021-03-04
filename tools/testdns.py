#! /usr/bin/python
# ops535 tools for testing DNS servers
# caching: 192.168.x.3
# primary: 192.168.x.2
# root: 192.168.x.4

import dns.resolver

network_id = input("Your Network ID (1-43): ")
domain_name = input("Your Domain name: ")

pri_dns = '.'.join(['192','168',network_id,'2'])
co_dns = '.'.join(['192','168',network_id,'3'])
rns_dns = '.'.join(['192','168',network_id,'4'])

print("Testing your DNS server, IP ",pri_dns)
print("And your domain name is ", domain_name)

dummy = input("Press ENTER when ready:")

# fqdn to be tested:
# pri-dns.[domain-name] 192.168.x.2
# co-nfs.[domain-name] 192.168.x.3
# rns-ldap.[domain-name] 192.168.x.4

host_list = ['pri-dns','co-nfs','rns-ldap']
ip_address = ['192.168.2.2','192.168.2.3','192.168.2.4']

fqdn_s = []
for host in host_list:
    fqdn_s.append(".".join([host,domain_name]))

myResolver = dns.resolver.Resolver()
# testing primary dns server 

myResolver.nameservers=[pri_dns]
try:
    myAnswers=myResolver.query(domain_name,"SOA")
    for rdata in myAnswers:
        print(rdata)
        print("email: ",rdata.rname)
        print("server: ",rdata.mname)
        print("serial no: ",rdata.serial)

except:
    print("SOA Query failed.")

for fqdn in fqdn_s:
    try:
        myAnswers = myResolver.query(fqdn,"A")
        print('Query result for:',fqdn)
        for rdata in myAnswers:
            print('Answer:',rdata)

    except:
        print("Adderss query for',fqdn,'failed.")

# myResolver.read_resolv_conf("/etc/resolv.conf") <-- restore nameserver IP
