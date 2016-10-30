#! /usr/bin/python
# ops535 tools for testing DNS servers
# caching: 192.168.x.153
# primary: 192.168.x.53
# root: 192.168.x.253

import dns.resolver

network_id = raw_input("Your Network ID (1-32): ")
domain_name = raw_input("Your Domain name: ")

pri_dns = '.'.join(['192','168',network_id,'53'])
co_dns = '.'.join(['192','168',network_id,'153'])
rns_dns = '.'.join(['192','168',network_id,'253'])

print "Testing your DNS server, IP ",pri_dns
print "And your domain name is ", domain_name

dummy = raw_input("Press ENTER when ready:")

# fqdn to be tested:
# sdn.[domain-name] 192.168.x.33
# neutron.[domain-name] 192.168.x.66
#
# hosts=['sdn','neutron']
# a records: a_rec=".".join([hosts[0],domain_name])
#
myResolver = dns.resolver.Resolver()
myResolver.nameservers=[pri_dns]
try:
	myAnswers=myResolver.query("cp.net","SOA")
	for rdata in myAnswers:
		print rdata
		print "email: ",rdata.rname
		print "server: ",rdata.mname
		print "serial no: ",rdata.serial

except:
	print "SOA Query failed."

try:
	myAnswers = myResolver.query("pri.cp.net","A")
	for rdata in myAnswers:
		print rdata

except:
	print "Adderss query for pri failed."


# myResolver.read_resolv_conf("/etc/resolv.conf") <-- restore nameserver IP
