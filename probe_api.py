import urllib.request
import urllib.parse
import json
import ssl

base_url = "https://suchigoapis.pythonanywhere.com/api/"
endpoints = [
    "send-otp", "send_otp", "otp", "request-otp", "request_otp",
    "generate-otp", "generate_otp", "sms", "send-sms", "send_sms",
    "phone", "verification", "verify", "register", "register/otp",
    "otp/send", "otp/request", "otp/generate", "sendotp", "send_otp_code",
    "send-otp-code", "generate-otp-code", "request-otp-code"
]

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

for ep in endpoints:
    url = f"{base_url}{ep}/"
    
    # Try GET
    try:
        req = urllib.request.Request(url, method="GET")
        with urllib.request.urlopen(req, context=ctx, timeout=5) as response:
            status = response.status
            body = response.read().decode('utf-8')
            print(f"GET {url} -> status={status}")
            print(f"  Response: {body[:200]}")
    except urllib.error.HTTPError as e:
        if e.code != 404:
            print(f"GET {url} -> status={e.code}")
            try:
                print(f"  Response: {e.read().decode('utf-8')[:200]}")
            except Exception as ex:
                print(f"  Read failed: {ex}")
    except Exception as e:
        print(f"GET {url} failed: {type(e).__name__}: {e}")

    # Try POST
    try:
        data = json.dumps({"phone_number": "+918281535237"}).encode('utf-8')
        req = urllib.request.Request(
            url,
            data=data,
            headers={"Content-Type": "application/json"},
            method="POST"
        )
        with urllib.request.urlopen(req, context=ctx, timeout=5) as response:
            status = response.status
            body = response.read().decode('utf-8')
            print(f"POST {url} -> status={status}")
            print(f"  Response: {body[:200]}")
    except urllib.error.HTTPError as e:
        if e.code != 404:
            print(f"POST {url} -> status={e.code}")
            try:
                print(f"  Response: {e.read().decode('utf-8')[:200]}")
            except Exception as ex:
                print(f"  Read failed: {ex}")
    except Exception as e:
        print(f"POST {url} failed: {type(e).__name__}: {e}")
