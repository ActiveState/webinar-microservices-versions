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

## Deployment flow

Recommend deployment flow for both mutable and immutable application versions...

1. Deploy v1 of /greeting

This results in "Hello there!" being returned from /greeting

2. Deploy v1 of /name

This still results in "Hello there!" being returned from /greeting

3. Deploy v2 of /greeting

v2 is aware of the /name v1 endpoint and will start consuming it. You will now see "Hello Phil!".

NOTE: The previous 2 steps can be done in either order, but best to deploy /name and test is first.

4. Deploy v2 of /name

This will result in /greeting returning "['Phil', 'John']" (only for /v2/name. /v1/name still returns "Phil"). Since /v2/greeting only knows about /v1/name, it will still return "Hello Phil!"

5. Deploy v3 of /greeting

This is results in /v2/name aware /greeting. Now /greeting will return "Hello Phil and John!".

6. Deploy v1 of /hi-word

No change to /greeting, since it is unaware of this endpoint.

7. Deploy v4 of /greeting

/v4/greeting know about /hi-word and will start consuming it resulting in "Hola Phil and John!"

8. Rollback

If you being to rollback through these steps, the system should fallback and degradate functionality gracefully.

9. Replicate failure

From step 7 you should be able to kill the most recent version of any service or jump back to a previous version and they system should tolerate this and degrade functionality gracefully. Note, if you completely kill the root /greeting application then you will have no entrypoint in the system, but you should be able to jump back to any version. You will find that immutable infrastructure handles this scenario best, since killing v3 does not affect v2 or v1 instances, whereas with immutable they are all in the same application, which is backwards compatible.

