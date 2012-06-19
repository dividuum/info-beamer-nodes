import sys
import json
import twitter
import urllib
import datetime
import pprint

api = twitter.Api()

tweets = [dict(
    user = tweet.user.screen_name,
    text = tweet.text,
    image = tweet.user.profile_image_url,
    time = datetime.datetime.fromtimestamp(tweet.created_at_in_seconds).strftime("%H:%M"),
) for tweet in api.GetSearch(sys.argv[1])]

for n, tweet in enumerate(tweets):
    img = "profile-image%02d" % (n+1)
    out = file(img, "wb")
    out.write(urllib.urlopen(tweet['image']).read())
    out.close()
    tweet['image'] = img
    pprint.pprint(tweet)

file("tweets.json", "wb").write(json.dumps(tweets, ensure_ascii=False).encode("utf8"))
