import sys
import json
import twitter
import urllib
import datetime
from cStringIO import StringIO
from PIL import Image

api = twitter.Api(debugHTTP=True,use_gzip_compression=True)

tweets = [dict(
    user = tweet.user.screen_name,
    text = tweet.text,
    image = tweet.user.profile_image_url,
    time = datetime.datetime.fromtimestamp(tweet.created_at_in_seconds).strftime("%H:%M"),
    sec = tweet.created_at_in_seconds,
    ) for tweet in api.GetSearch(
        sys.argv[1],
        per_page = 20,
        result_type = "recent",
    ) if not (
        tweet.text.startswith('@') or tweet.text.startswith("RT")
    )
]

for n, tweet in enumerate(tweets):
    img = "profile%02d" % (n+1)
    image = Image.open(StringIO(urllib.urlopen(tweet['image']).read()))
    image.convert('RGB').save(img, 'JPEG')
    tweet['image'] = img
    print tweet['time'], repr(tweet['text'])

file("tweets.json", "wb").write(json.dumps(tweets,ensure_ascii=False).encode("utf8"))
