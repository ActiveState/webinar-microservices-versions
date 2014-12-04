Simple example of versioned provider-consumer on Stackato. This demonstrates two types of applications versioning - mutable and immutable.

## Mutable Versions

Mutable versions are versions where one replaces the other. Stackato is able to replace one version with another or rollback to a previous version. With these mutable versions, each version of the application shares the same application name (e.g. "provider") and only one version of each application is running at one time.

Mutable versions should be backwards compatible. Therefore, v1 should provide /v1/name and v2 should provide both /v1/name and /v2/name.

## Immutable Versions

Immutable versions are versions that run potentially forever. For instance, v1 is pushed and is not taken down when v2 is pushed. Therefore, in this example, each version of the application has a different application name (e.g. "provider-v1", "provider-v2", "provider-v3"...). This results in multiple versions running in parallel. If the newer version fails then the consumer can fallback to the previous version, which remains untouched.

Immutable versions do not need to be backwards compatible, as mutable versions are. Therefore, v1 should provide /v1/name and v2 only needs to provide /v2/name.

## Provider-Consumer

In our example, we have a provider, which exposes an API /name, which simply returns a name. Since this is versioned, the URL will be /v1/name, /v2/name or /v3/name. Depending on whether this is mutable or immutable the host will also include the version.

The consumer works in the same way. It provides an endpoint /greeting which will return "Hello <name>!", where <name> is retrieved from the name provider. We also version this in the same way, so it will be /v1/greeting or /v2/greeting and the hostname will include the version if we are using immutable applications.

## Independent upgrades and graceful fallback

If the /name endpoint is unavailable for the requires version (eg. v2) it will fallback to the previous version (eg. v1). If not versions are available the /greeting endpoint will fallback to returning "Hello there!".

When we push v2 of /greeting, the greeting will change from "Hello <name>!" (or "Hello there!") to "Hi <name>! How are you doing?" (or "Hi there! How are you doing?"). When we push v2 of /name it will change the response from returning a string "Phil" to returning a JSON array "['Phil', 'John']".

## Multiple Providers

Extending this further, our /greeting endpoint will start to consume a 2nd provider, if it is available. This 2nd provider provides the "Hi" for our greeting, but will return random variations of "Hi" (but not "Hi") with the fallback being "Hi". This new endpoint will be /hi-word

## Deployment

Here is the recommended deployment...

```
# Clone the repo
git clone git@github.com:ActiveState/webinar-microservices-versions.git
cd webinar-microservices-versions
cd immutable

# Deploy all services in stopped state
util/deployment.sh

# Start the frontend application.
# This is our entry-point into the system.
stackato start frontend-v1

# In a different terminal, start polling the frontend.
# Should see "Service is down" initially.
util/util/poll-frontend.sh
```

Now, let's start deploying our services. Actually, ```util/deployment.sh``` would have deployed them all already, and we'll just start them below, but if you want you could deploy them here as well.

As mentioned above, you should be running poll-frontend.sh in a separate terminal which polls the frontend app. From this you should never see a 500 Internal Server Error returned by frontend, once it is deployed, as each step below should result in zero down-time and gracefully switch over to newer functionality as it is deployed.

1. Deploy v1 of /greeting

   This is a Node.js app that just returns ```"Hello there!"``` from ```/v1/greeting```

   ```
   stackato start greeting-v1
   ```

   This results in ```"Hello there!"``` being returned from our frontend app.

2. Deploy v1 of /name

   This is a Go application that returns ```"Phil"``` from ```/v1/name```

   ```
   stackato start name-v1
   ```

   This still results in ```"Hello there!"``` being returned from our frontend app.

3. Deploy v2 of /greeting

   This is a Ruby Sinatra app that just returns ```"Hello <name>!"``` from ```/v2/greeting```, where ```<name>``` is retrieved from ```/v1/name``` of the ```name-v1``` application. If ```name-v1``` is unavailable it will fall back to returning ```"Hello there!"```

   ```
   stackato start greeting-v2
   ```

   v2 is aware of the /name v1 endpoint and will start consuming it. You will now see ```"Hello Phil!"``` returned from our frontend app.

4. Deploy v2 of /name

   This is a Go application that returns ```["Phil","John"]``` from ```/v2/name``` and the content-type header of ```application/json```.

   ```
   stackato start name-v2
   ```

   Since /v2/greeting only knows about /v1/name, our frontend app will still return "Hello Phil!"

5. Deploy v3 of /greeting

   Similar to v2, this is a Ruby Sinatra app that just returns ```"Hello <name>!"``` from ```/v3/greeting```, where ```<name>``` is retrieved from ```/v2/name``` of the ```name-v2``` application, if available. Since, ```/v2/name``` returns JSON, it will decode it and format it as ```"Phil and John"```. Other it will act the same as v2 of ```/greeting```, using ```/v1/name``` of the ```name-v1``` app. If ```name-v1``` is unavailable it will fall back to returning ```"Hello there!"```

   ```
   stackato start greeting-v3
   ```

   This is results in a greeting which is /v2/name aware and knows how to use the JSON returned from it. Now /greeting will return ```"Hello Phil and John!"```.

6. Deploy v1 of /hi-word

   This is Python app that returns a random world ('Bonjour', 'Hola', 'Hi', 'Hallo' or 'Ciao').

   ```
   stackato start hi-word-v1
   ```

   No change to the output of our frontend app, since nothing is unaware or consuming this new service.

7. Deploy v4 of /greeting

   Similar to v3, this is Python app that consumes v2 or v1 of the /name service in the same way. It also consumes the hi-word app to replace the word "Hello" with another random greeting. If no hi-word service is available it will fall back to "Hello".

   ```
   stackato start greeting-v4
   ```

   Since the /v4/greeting knows about /v1/hi-word, it will start consuming it resulting in "Hola Phil and John!" or "Bonjour Phil and John!" or "Hi Phil and John!" or other random greetings other than "Hello".

8. Rollback

   If you begin to roll back through these steps, the system should fallback and degradate functionality gracefully.

   e.g.
   ```
   stackato stop greeting-v4
   ```

9. Replicate failure

   name-v1 and name-v2 also have /crash handlers which if you visit that in your web browser or via curl, it will cause the process to crash. You then see the output of the frontend app change (degrade gracefully). A few seconds later Stackato will bring up a new version of that instance and the original output will resume.

   You also can stop any app version with ```stackato stop <app-name>```, (e.g. ```stackato stop name-v2```), but Stackato will not restart it since you have told it explicitly to stop the app.

   From step 7 you should be able to stop the most recent version of any service or jump back to a previous version and they microservices architecture in this example should tolerate this and degrade functionality gracefully. You will find that immutable infrastructure handles this scenario best, since stopping v3 does not affect v2 or v1 instances, whereas with mutable infrastructure they are all in the same application, which is backwards compatible.

10. Deleting all apps

   This will delete all the app deployed by ```util/deployment.sh```

   ```
   util/delete-all.sh
   ```
