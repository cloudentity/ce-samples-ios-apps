
# iOS Application using PKCE & Cloudentity Authorization Platform

This sample iOS application obtains an access token from [Cloudentity Authorization Platform](https://cloudentity.com/) using Authorization Code grant and PKCE. 

## Prerequisites
 - [Cloudentity Authorization Platform account](https://authz.cloudentity.io/register)
 - [Workspace and Client application prepared for PKCE](https://docs.authorization.cloudentity.com/features/oauth/grant_flows/auth_code_with_pkce/?q=pkce)
 - Xcode 13+
 - iOS 15+
 
 ## Introduction
Care must be taken when using OAuth 2.0 when building mobile applications since these are untrusted clients. An application developer should not store secrets in these applications since they can be decompiled and the secrets extracted. Furthermore, in the case of mobile and native applications it is possible for multiple applications to register the same custom URL scheme. The behaviour is then undefined for which application will receive the callback from the authorization server. These concerns can be mitigated by using PKCE(Proof Key for Code Exchange). In this tutorial a simple iOS application will be created using PKCE with the authorization code grant. AuthenticationServices provided by the iOS SDK will also be used as it offers a browser that the developer cannot access and prevents rogue applications from receiving the authorization server callback. This application will follow best practices as described in [OAUTH for Native Apps](https://datatracker.ietf.org/doc/html/rfc8252).


 ## Prepare Cloudentity Workspace
 Configure your workspace by creating a new client application or use an existing application. ![Set the Token Endpoint Authentication Method to None](https://github.com/cloudentity/ce-samples-ios-apps/img/auth_method.png?raw=true.png)
 
 Optionally, in Auth Settings under the General tab turn on 'Enforce PKCE for all clients'. 
 ![turn on Enforce PKCE for all clients](https://github.com/cloudentity/ce-samples-ios-apps/img/enforce_all.png?raw=true.png)

 Copy the Client ID, token endpoint, and authorization endpoints from the OAuth tab. Then set the redirect URI. The redirect URI should include your custom URL scheme and the reverse DNS string that incorporates your company's domain and application name. This is important to ensure uniqueness. 
![set application redirect_uri](https://github.com/cloudentity/ce-samples-ios-apps/img/redirect_uri.png?raw=true.png)

 In the sample iOS application, the identifier is set to 'com.example.simple-pkce' and the scheme is set to 'oauth' as shown in the next section. Therefore, in your workspace client application set the redirect URI to 'oauth://com.example.simple-pkce'. In a real application choose an appropirate scheme and reverse DNS string.

## Preparing the sample iOS application
Set the values of the Client ID, token endpoint URL, authorize endpoint URL in the Info.plist of the sample application in Custom iOS Target Properties in Xcode.
![set application parameters in XCode](https://github.com/cloudentity/ce-samples-ios-apps/img/plist_values.png?raw=true.png)

In URL Types set the Identifier to the reverse DNS string that incorporates your domain and application name and set URL Schemes to your chosen scheme ensuring that the values match the redirect URI that was set in the previous section. If the values set in the previous section match the sample application then no change is required for this step.
![url scheme and identifier](https://github.com/cloudentity/ce-samples-ios-apps/img/scheme_settings_identifier.png?raw=true.png)

You can also set the values for the identifier, scheme, endpoints URLs, and client ID directly in the Info.plis as shown.
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AuthorizeEndpoint</key>
	<string>--enter authorize URL goes here--</string>
	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeRole</key>
			<string>Viewer</string>
			<key>CFBundleURLName</key>
			<string>--enter reverse DNS string here--</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>--enter scheme here--</string>
			</array>
		</dict>
	</array>
	<key>ClientID</key>
	<string>--enter client ID goes here--</string>
	<key>TokenEndpoint</key>
	<string>--enter token endpoint URL here--</string>
</dict>
</plist>
```

Note that a custom URL scheme is used. Since we are using the iOS SDK AuthenticationServices Apple helps protect the application from rogue apps getting the callback from the authorization server. However, when not using AuthenticationServices it is possible for multiple applications to register the same callback. This is where PKCE will be helpful because any app that receives the callback with the authorization code will also need the corresponding code verifier for the code challenge presented to the authorization server. This will be explored more in the following sections.

## Running the application

Run the application and verify there are no errors. You should see the sign-in screen as shown below. 
![sign in screen](https://github.com/cloudentity/ce-samples-ios-apps/img/main.png?raw=true.png)

Now log in to the application by tapping 'Sign In'. You should see no errors and be presented with the Cloudentity OAuth sign in modal. 
![oauth sign in screen](https://github.com/cloudentity/ce-samples-ios-apps/img/modal.png?raw=true.png)

You can view the token header and the payload by selecting the corresponding tabs from the home screen upon successful login. Additionally, there is a tab for Resources. The Resources tab will be explored further in the next section.

## Exploring the code

The relevant portion of the code for handling the authentication flow can be seen in the Helpers folder in Authenticator.swift. The Authenticator class uses AuthenticationServices to simplify the authentication flow. It also restricts access to the browser presented to the user because the application developer cannot access what the user enters since it is an external user-agent. Developers should not use an embedded webview since the users entries could be visible to the developer. Furthermore, an embedded view would not share session data with the mobile applications primary browser.  

The `authenticate()` method starts the authentication flow by first generating a code verifier as explained in [RFC 7636](https://datatracker.ietf.org/doc/html/rfc7636). The `authenticate()` method then gets the authentication endpoint URL and required parameters. In the next section the authentication URL and its parameters will be explored in more detail. In the event the authentication URL is not set then an error is returned. Notice that since PKCE is being used a code challenge, generated from the code verifier, is included as required by [RFC 7637](https://datatracker.ietf.org/doc/html/rfc7636)

```swift
func authenticate() {
        codeGenerator.generateVerifier()
        
        guard let authURL = URL(string: AuthConfig.authEndpoint)?.getAuthURL(clientID: AuthConfig.clientID, challenge: codeGenerator.getChallenge(), urlScheme: AuthConfig.urlScheme) else {
            self.completion(nil, .failedToSetAuthURL)
            return
        }
```

An ASWebAuthenticationSession is obtained by providing the authentication URL with required parameters and the callback URL scheme. In the callback a check is performed for an error. If there is no error the callback URL is verified to be present and it is verified that no error was returned from the OAuth server. Finally, the code is extracted from the query parameters and passed to `fetchToken(code: String)`.

```swift
let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "oauth")
        { [self] callbackURL, error in
            
            guard error == nil else {
                self.completion(nil, .cancelled)
                return
            }

            guard let callbackURL = callbackURL else {
                self.completion(nil, .callbackMissingCallbackURL)
                return
            }
            
            guard callbackURL.getQueryParam(value: "error") == nil else {
                self.completion(nil, .errorReturnedFromAuthorize(callbackURL.getQueryParam(value: "error")!))
                return
            }
            
            guard let code = callbackURL.getQueryParam(value: "code") else {
                self.completion(nil, .callbackMissingCode)
                return
            }

            self.fetchToken(code: code)
        }
        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = true
        session.start()
```

The `fetchToken(code: String)` method retreives the code verifier and then creats a URLRequest using the code verifier and the authorization code returned from the Cloudentity client application. A request for the token to the token endpoint is then made. If there is an error then the UI is updated with the error, otherwise the token is saved and the user is presented with the application home screen.

```swift
private func fetchToken(code: String) {
        guard let url = URL(string: AuthConfig.tokenEndpoint) else {
            self.completion(nil, .failedToGetTokenEndpoint)
            return
        }
        
        let verifier = self.codeGenerator.getVerifier()
        let request = url.getTokenRequest(clientID: AuthConfig.clientID, verifier: verifier, code: code, urlScheme: AuthConfig.urlScheme)
        
        URLSession.shared.dataTask(with: request) { [weak self]
            data,_,err in
            if err != nil {
                self?.completion(nil, .tokenRequestFailed(err!))
                return
            }
            
            DispatchQueue.main.async {
                guard let data = data else {
                    self?.completion(nil, .unableToParseTokenResponse)
                    return
                }
                do {
                    let v = try JSONDecoder().decode(TokenResponse.self, from: data)
                    self?.completion(v, nil)
                } catch {
                    self?.completion(nil, .unableToParseTokenResponse)
                }
            }
        }.resume()
    }
```

When making an authorization request scopes are requested. In addition to the code challenge the request also requires the code challenge method, the redirect URI, the client ID, and in this case a response type of `code`. 


This authorization URL is constructed in URLExtensions.swift in the `getAuthURL` method. In addition to the usual parameters, the `code_challenge` and `code_challenge_method` are sent in the request. This is also where the requested scopes are added to the request.
 
 ```swift
 func getAuthURL(clientID: String, challenge: String, urlScheme: String) -> URL? {
        guard var components = URLComponents(string: self.absoluteString) else {
            return nil
        }
        
        components.queryItems = [
            URLQueryItem(name:"client_id", value: clientID),
            URLQueryItem(name:"redirect_uri", value: urlScheme),
            URLQueryItem(name:"response_type", value: "code"),
            URLQueryItem(name:"scope", value: "email openid profile"),
            URLQueryItem(name:"code_challenge", value: challenge),
            URLQueryItem(name:"code_challenge_method", value: "S256"),
        ]
        
        return components.url
    }
```

This file also contains the `getTokenRequest` method which is used to create a request and set the necessary query parameters for getting the access token using the authorization code. The `code_verifier` is included in the request so the authorization server can verify that this is the application for which the authorization code was intended. 

```swift
func getTokenRequest(clientID: String, verifier: String, code: String, urlScheme: String) -> URLRequest {
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name:"client_id", value: clientID),
            URLQueryItem(name:"redirect_uri", value: urlScheme),
            URLQueryItem(name:"grant_type", value: "authorization_code"),
            URLQueryItem(name:"code_verifier", value: verifier),
            URLQueryItem(name:"code", value: code),
        ]
        
        return buildRequest(components: components)
    }
```

Recalling the Resources tab in the sample application, the scopes can be used to control which buttons are present, the titles the buttons have, and the resource that will be accessed when a button is tapped. In the sample application the scopes are set to `email openid profile`. Open the `scopeData.json` file under Resources in the project.

```json
[
    {
        "scope":"openid",
        "title": "Transfer",
        "url": "http://localhost:8080/banking/transfer"
    },
    {
        "scope":"email",
        "title": "Balance",
        "url": "http://localhost:8080/banking/balance"
    },
    {
        "scope":"profile",
        "title": "Some name",
        "url": "http://localhost:8080/pets/pet/2"
    },
    {
        "scope":"phone",
        "title": "Phone",
        "url": "http://localhost:8080/pets/pet/1"
    }
]
```

This file contains a list of possible buttons as shown.
![resoure buttons](https://github.com/cloudentity/ce-samples-ios-apps/img/buttons.png?raw=true.png)

Notice the sample application requested three scopes, `email openid profile`, but `scopeData.json` shows four entries. Upon receiving authorization, the application will iterate over the scopes in `scopeData.json` and for each scope granted to the application if there is a corresponding scope in this file then a button will be displayed.  Each entry in `scopeData.json` represents a JSON object with three fields. `scope` is a scope that the application could request. The `url` is for a protected resource that the application would like to access. The `title` key sets the title that is displayed on the button. Try changing the `title` value for a few buttons and run the application to see the updated title. Change scopes requested by removing one of the scopes and verify that the application only displays two buttons after logging in to the application.

## Conclusion
A simple iOS application was created which obtains an access token using Cloudentity authorization platform. PKCE was used with the authorization code flow ensuring that only this application can obtain an access token using the authorization code returned from the authorization server.  If another application used the same custom URL scheme and obtained the authorization code it would not be able to obtain an access token because it would not have the correct code verifier. Cloudentity Authorization Platform conforms to the current OAuth 2.0 standards and facilitates creating secure mobile applications that protects users and enables developers to build applications quickly and easily with security in mind.

 
Relevant Links
 - [OAUTH](https://datatracker.ietf.org/doc/html/rfc6749)
 - [OAUTH for Native Apps](https://datatracker.ietf.org/doc/html/rfc8252)
 - [PKCE](https://datatracker.ietf.org/doc/html/rfc7636)

