import requests
import random
import time
import urllib3

# Disable the InsecureRequestWarning
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Set up a proxies dictionary with None to disable proxy
proxies = {
    "http": None,
    "https": None,
}

# Authenticate
url = "https://198.18.1.101/api/aaaLogin.json"
auth = {
    "aaaUser": {
        "attributes": {
            "name": "admin",
            "pwd": "C!sc0123"
        }
    }
}
session = requests.post(url, json=auth, verify=False, proxies=proxies)
token = session.json()['imdata'][0]['aaaLogin']['attributes']['token']
cookies = {'APIC-Cookie': token}

for x in range(5):
# Create fvStCEp
    random_ip = "192.168.15." + str(random.randint(10, 252))
    random_mac = "05:00:15:%02x:%02x:%02x" % (random.randint(0, 255), random.randint(0, 255), random.randint(0, 255))
    random_mac = random_mac.upper()
    print('### MAC/IP Pair:')
    print(random_mac)
    print(random_ip)

    stcep_url = f"https://198.18.1.101/api/node/mo/uni/tn-Tenant1/ap-APP-B/epg-15-DB/stcep-{random_mac}-type-silent-host.json"
    stcep_data = {
      "fvStCEp": {
        "attributes": {
          "dn": f"uni/tn-Tenant1/ap-APP-B/epg-15-DB/stcep-{random_mac}-type-silent-host",
          "mac": random_mac,
          "encap": "vlan-15",
          "rn": f"stcep-{random_mac}-type-silent-host",
          "status": "created"
        },
        "children": [
          {
            "fvRsStCEpToPathEp": {
              "attributes": {
                "tDn": "topology/pod-1/paths-101/pathep-[eth1/1]",
                "status": "created"
              },
              "children": []
            }
          }
        ]
      }
    }
    response1 = requests.post(stcep_url, json=stcep_data, cookies=cookies, verify=False, proxies=proxies)
    print(response1.status_code)

    time.sleep(1)

# Create fvIP

    fv_ip_url = f"https://198.18.1.101/api/node/mo/uni/tn-Tenant1/ap-APP-B/epg-15-DB/cep-{random_mac}.json"
    ip_data = {
        "fvIp": {
            "attributes": {
                "addr": random_ip
            }
        }
    }
    response2 = requests.post(fv_ip_url, json=ip_data, cookies=cookies, verify=False, proxies=proxies)
    print(response2.status_code)
