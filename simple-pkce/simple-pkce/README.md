
# iOS Application using PKCE & Cloudentity Authorization Platform

This sample iOS application obtains an access token from [Cloudentity Authorization Platform](https://cloudentity.com/) using Authorization Code grant and PKCE.

## Prerequisites
 - [Cloudentity Authorization Platform account](https://authz.cloudentity.io/register)
 - [Workspace and Client application prepared for PKCE](https://docs.authorization.cloudentity.com/features/oauth/grant_flows/auth_code_with_pkce/?q=pkce)
 
## Running the sample application
 - Clone the repository and open the `simple-pkce` folder in Xcode. 
 - Add your client application credentials to `AuthConfig` in `Authenticator.swift`
 - Run the application in Xcode by selecting **Product** > **Run**
 
 
Relevant Links
 - [OAUTH](https://datatracker.ietf.org/doc/html/rfc6749)
 - [OAUTH for Native Apps](https://datatracker.ietf.org/doc/html/rfc8252)
 - [PKCE](https://datatracker.ietf.org/doc/html/rfc7636)

