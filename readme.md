# GlookoScout

A lightweight automation script that pulls historical glucose data from Nightscout and automatically uploads it to Glooko by mimicking an Abbott LibreView CSV import. 

⚠️Code maturity: Very alpha(!)⚠️

## Prerequisites
- Python 3.8+
- Google Chrome installed on your machine
- A Nightscout instance set to `mmol/L`
- (I build and tested this on Ubuntu running in WSL)

## Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/wessec/glookoscout.git
   cd glookoscout
   ```
2. **Install dependencies:**

    ```bash
    pip install -r requirements.txt
    ```

3. **Configure environment:**
Copy the example configuration file and fill in your details:

    ```bash
    cp .env.example .env
    ```
|Variable|Description|Example|
|--- |--- |--- |
|NIGHTSCOUT_URL|The full URL of your Nightscout instance (no trailing slash).|https://ns.yourdomain.com|
|NIGHTSCOUT_API_TOKEN|A readable API token. Generate this in the Nightscout Admin settings.|mytoken-12345abcdef|
|PAST_DAYS|Number of days of historical glucose data to fetch and upload. Please note that historic data in glooko will be overwritten on each upload|30|
|GENERATOR_NAME|The name attached to the generated LibreView CSV file.|John Doe|
|LIBRE_SERIAL_NUMBER|A unique identifier for your "device". This can be any random string (like a UUID), but it must remain exactly the same across all your uploads so Glooko groups the data correctly. You can generate a random UUID at https://www.uuidgenerator.net/|64448acc-c17a-4f79-af29-c0e674b874c9|
|GLOOKO_EMAIL|The email address you use to log into Glooko.|user@domain.com|
|GLOOKO_PASSWORD|The password for your Glooko account.|SuperSecret123!|
|HEADLESS_BROWSER|Set to False to watch the browser perform the upload visually. Set to True to run it invisibly in the background.|True|
|APPRISE_URL|(Optional) An [Apprise](https://github.com/caronc/apprise) notification URL. If configured, you will receive a push notification if the script encounters an error fetching data or if the Glooko upload fails. You can use this to send alerts to Discord, Slack, Ntfy, Telegram, and many more.|ntfy://ntfy.sh/mysecretglookotopic|
|UPTIME_KUMA_URL|(Optional) An Uptime Kuma Push URL. If configured, the script will ping this URL only when the Glooko upload finishes successfully, allowing you to monitor your daily syncs.|http://<kuma_server>:3001/api/push/<token>?status=up&msg=OK&ping=|

⚠️ SECURITY WARNING: Your Glooko password is stored in plain text inside the file. Do not commit this file to version control (it is excluded in by default). Because of this, it is highly recommended that you use a strong, unique password for your Glooko account that you do not use anywhere else.

## Usage

Run the sync script:

```bash
python sync.py
```

By default, the script runs in headless mode (the browser is hidden). If you encounter Captcha issues or want to watch the upload process, change in your .env: `HEADLESS_BROWSER=False`

### Automation

You can easily automate this script with a cron like  
Please be nice to the glooko servers, lower your lookback period if you do daily uploads:

`0 7 * * * cd ~/scripts/glookoscout && /usr/bin/python3 sync.py >> ~/scripts/glookoscout/sync.log 2>&1`

#### Uptime Kuma Monitoring

If you are running the script on a daily schedule (e.g., every 24 hours via cron) and want to monitor it with Uptime Kuma:

1. Create a new monitor of type Push.
2. Copy the Push URL and set it as your UPTIME_KUMA_URL in .env.
3. In your Uptime Kuma monitor settings, change the Heartbeat Interval to 87000 seconds (slightly more than 24 hours to give the script a short grace period to run).
If the sync ever crashes or fails the Glooko upload, Kuma won't receive the ping and will alert you that the job went down.
