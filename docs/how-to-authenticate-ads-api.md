# How to authenticate Google Ads API
Regardless of a client you use you will need the following parameters to authenticate your Ads API calls:  
* `developer_token` - we can get developer_token from any of your Google Ads MCC account, see [Prerequisites](https://developers.google.com/google-ads/api/docs/first-call/overview#prerequisites) for details
* `client_id` and `client_secret` - The OAuth2 client ID and client secret map your client app to a project in the Google API Console and are used for OAuth2 authentication
* `refresh_token` - this is a value you should obtain before making any call, it's bound to your Google account, see below
* `login_customer_id` (optional) - see https://developers.google.com/google-ads/api/docs/concepts/call-structure#cid (Id should be in 11111111 format, do not add dashes as separator)

Please note that `client_id` and `client_secret` aren't required if you use [OAuth Service Account Flow](https://developers.google.com/google-ads/api/docs/client-libs/python/oauth-service).
But please be aware that it requires using Google Workspace.

Useful Resources:
* [Google Ads API Prerequisites](https://developers.google.com/google-ads/api/docs/first-call/overview#prerequisites)
* [OAuth2 in the Google Ads API](https://developers.google.com/google-ads/api/docs/oauth/overview)
* [Using OAuth 2.0 to Access Google APIs](https://developers.google.com/identity/protocols/oauth2)
* [OAuth Desktop and Web Application Flows](https://developers.google.com/google-ads/api/docs/client-libs/python/oauth-web)
* [Control API access with domain-wide delegation](https://support.google.com/a/answer/162106) (Google Workspace docs)


## Steps

1. [Get Google Ads Developer Token](https://developers.google.com/google-ads/api/docs/first-call/dev-token)

2. Setup Google Cloud project and OAuth client id

You need a Google Cloud project with enabled Google Ads API. 
See details here: [Configure a Google API Console Project for the Google Ads API](https://developers.google.com/google-ads/api/docs/oauth/cloud-project)

Create an OAuth credentials (for the first time you'll need to create a consent screen either).
Please note you need to generate OAuth2 credentials for **desktop application**.


3. Generate refresh token

>Before proceeding with token generation you need to make sure that either [your oauth brand](https://console.cloud.google.com/apis/credentials/consent)
made public (published) or you added yourself as a test user if it's in testing status (it's not recommended because refresh tokens will exprire in 7 days).

  3.1. Generate refresh token using `oauth2l`

First you need to download [oauth2l](https://github.com/google/oauth2l) tool ("oauth tool").
For Windows and Linux please download [pre-compiled binaries](https://github.com/google/oauth2l#pre-compiled-binaries),
for MacOS you can install via Homebrew: `brew install oauth2l`.

As soon as you generated OAuth2 credentials:
* Click the download icon next to the credentials that you just created and save file to your computer
* Copy the file name under which you saved secrets file -
`~/client_secret_XXX.apps.googleusercontent.com.json` where XXX will be values specific to your project 
(or just save it under `client_secret.json` name for simplicity)
* Run desktop authentication with downloaded credentials file using `oauth2l` in the same folder where you put the downloaded secret file (assuming its name is client_secret.json):
```
oauth2l fetch --credentials ./client_secret.json  --scope adwords --output_format refresh_token
```
* Copy a refresh token from the output


  3.2. Generate refresh token using OAuth Playground

Alternately (if you can't or don't want to download anything locally) you can use [OAuth Playground](https://developers.google.com/oauthplayground/).
Please follow guidence in this video for setting up Web Flow with the OAuth Playground - https://www.youtube.com/watch?v=KFICa7Ngzng&t=812s

Please note you'll need to use another OAuth2 credentials type - Web application, and set "https://developers.google.com/oauthplayground" as redirect url in it.


  3.3. Generate refresh token using `generate_user_credentials.py`

If you have Python 3 installed on your machine, instead of downloading oauth2l tool you can use a Python script with the following one-liner
(run it in a folder with client_secret.json file containing your OAuth client id or adapt the file name in the command):
```
curl -s https://raw.githubusercontent.com/googleads/google-ads-python/main/examples/authentication/generate_user_credentials.py | python3 - -c=client_secret.json
```

4. What's next

Now you are all set. The only thing left is to put all parameters into a configuration file.
It depends on what version you're using: Python or NodeJS. Both of them support `google-ads.yaml` file.
And NodeJS support putting parameters into `.gaarfrc` as well. See its [README](../js/README.md).

Please note that all account ids (a.k.a customer ids) you put in configuration should be in 11111111 format, do not add dashes as separator.


## Setting up using `google-ads.yaml`
You can create `google-ads.yaml` in you home directory and it'll be used authomatically. 
Or you can create it wherever you want and supply the path to it via `--ads-config` command line argument. 
If the file is in the same folder where you running your scripts with executing gaarf then `google-ads.yaml` will be found automatically also.

Create `google-ads.yaml` file with the following content:
```
developer_token:
client_id:
client_secret:
refresh_token:
login_customer_id:
client_customer_id:
use_proto_plus: True
```
See full description of fields at [Configuration Fields](https://developers.google.com/google-ads/api/docs/client-libs/python/configuration#configuration_fields).

`client_customer_id` is optional here, and can be provided directly via the command line argument `--account`.

## Setting up using `.gaarfrc`
Inside your `.gaarfrc` create a section `ads` where put all parameters:
```json
{
 "ads": {
    "developer_token": "",
    "client_id": "",
    "client_secret": "",
    "refresh_token": ""
 },
 ...
}
```
