
# iOS Application using PKCE & Cloudentity Authorization Platform

This sample iOS application obtains an access token from [Cloudentity Authorization Platform](https://cloudentity.com/) using Authorization Code grant and PKCE. 

## Prerequisites
 - [Cloudentity Authorization Platform account](https://authz.cloudentity.io/register)
 - [Workspace and Client application prepared for PKCE](https://docs.authorization.cloudentity.com/features/oauth/grant_flows/auth_code_with_pkce/?q=pkce)
 - Xcode 13+
 - iOS 15+
 
## Running the sample application
 - Clone the repository and open the `simple-pkce` folder in Xcode. 
 - Add your client id as the value for the ClientID key in Info.plist
 - Add your workspace token URL as the value for the TokenEndpoint key in Info.plist
 - Add your workspace authorization URL as the value for the AuthorizeEndpoint key in Info.plist
 - Add your URL scheme in Info.plist [Register Your URL Scheme](https://developer.apple.com/documentation/xcode/defining-a-custom-url-scheme-for-your-app) Note: Can be left as-is `oauth://com.example.simple-pkce` and then add `oauth://com.example.simple-pkce` as the redirect uri in your client application.
 - Run the application in Xcode by selecting **Product** > **Run**
 
 
Relevant Links
 - [OAUTH](https://datatracker.ietf.org/doc/html/rfc6749)
 - [OAUTH for Native Apps](https://datatracker.ietf.org/doc/html/rfc8252)
 - [PKCE](https://datatracker.ietf.org/doc/html/rfc7636)

