#  PasskeysRails Demo App - iOS demonstration of using passkeys in stead of passwords

<p align="center" >
Created by <b>Troy Anderson, Allied Code</b> - <a href="https://alliedcode.com">alliedcode.com</a>
</p>

The purpose of this app is to demonstrate passkey implementation on iOS to authenticate with a back end server (relying party) that uses the passkeys-rails gem.

In passkeys terms, the iOS app is the `authenticator` and the server is the `relying party`.

This app requires a little configuration to work with your server.

## You are in the right place if:

1. You have a Rails application server in place that integrates the [passkeys-rails](https://github.com/alliedcode/passkeys-rails) gem.

2. You are planning to serve up API endpoints on your server that will require authentication for access.

3. You want to use passkeys to register and authenticate users because, among other things, you're tired of typing `Password123` all the time.

4. You want to integrate passkeys into your iOS, iPadOS, or MacOS app and are ready to see how easy it is to use passkeys to replace passwords.

## Setup - Team ID and Bundle Identifier
In the Signing & Capabilities tab of the PasskeyRailsDemo target change the Team to your Apple Developer Account Team and set the Bundle Identifier. These will be used to [setup your apple-app-site-association](#Ensure-`.well-known/apple-app-site-association`-is-in-place)

Your Team ID can be found in the Membership Details page of your [Apple Developer Account](https://developer.apple.com/account)

## Setup - Configure Associated Domains


### Edit the associated domain in your XCode project
The demo project ships with an Entitlements file and `webcredentials` configured for `example.com`. If your relying party server is at `my.server.com`, you would want to edit the associated domain entry to `webcredentials:my.server.com`.

As of this writing, Associated Domain entries are changed in XCode, in the Signing & Capabilities tab of your Target.

If `webcredentials` are not in place, the request to create passkey credentials will return an error. 

During testing it can be helpful to add a query string to the associated domain entry for example `webcredentials:my.server.com?mode=developer` - Further details can be found in [Apple's Associated Domains Entitlement Documentation](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_associated-domains)

### Ensure `.well-known/apple-app-site-association` is in place
The relying party (your server) must have a proper entry in the `.well-known/apple-app-site-association` file and that file must be publicly accessible via a GET request without any redirection.

For example, visiting `https://my.server.com/.well-known/apple-app-site-association` should serve content that looks something like:

```JSON 
{
   "webcredentials": {
      "apps": [
         "123456789N.com.server.my.appname"
      ]
   }
}
```
If the iOS device is unable to match the `webcredentials` and the `.well-known/apple-app-site-association`, the request to create passkey credentials will return an error. 

You can read more about supporting associated domains in [Apple's Supporting Associated Domains Documentation](https://developer.apple.com/documentation/xcode/supporting-associated-domains)

## Setup - Configure passkeys-rails

The `passkeys-rails` gem provides the handshaking required to implement registration and authentication with passkeys as well as expiring token authentication for other API endpoints on your server.

There are several configuration options available, but adding `passkeys-rails` to a Rails application and making the application accessible using a secure URL is all that is required to use this sample app.

You may want to consider using [ngrok.io](https://ngrok.io) or another similar service to serve your local development environment from a secure and publicly accessible URL (so your iPhone can find it).

## Helpful Documentation  

Learn more about passkeys-rails in the [README](https://github.com/alliedcode/passkeys-rails#readme).

Read more about supporting passkeys in [Apple's Supporting Passkeys Documentation](https://developer.apple.com/documentation/authenticationservices/public-private_key_authentication/supporting_passkeys/).

Apple has a good description of the [security of passkeys](https://support.apple.com/en-us/HT213305).  The first claim is that *Passkeys are a replacement for passwords. They are faster to sign in with, easier to use, and much more secure.*

Passkeys are built on the WebAuthentication (or "WebAuthn") standard, which uses public key cryptography.  They have some pretty [readable docs](https://webauthn.guide/) as well.
