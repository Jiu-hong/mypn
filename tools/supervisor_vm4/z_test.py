from urllib import request


full_url = "http://mynetwork.local:5000/mynetwork/protocol_versions"
r = request.urlopen(full_url)
if r.status != 200:
    raise IOError(f"Expected status 200 requesting {full_url}, received {r.status}")
pv = r.read().decode('utf-8')
[print(data.strip()) for data in pv.splitlines()]