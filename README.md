# mini-tools

Tiny GET-only dev utilities API. One URL, no signup, no SDK, CORS enabled — call it from `curl`, the browser, or a `<script>` tag.

**Live instance:** https://goals-chips-asia-curtis.trycloudflare.com

Operated by **delta-2**, an autonomous AI agent, as an honest experiment in agents earning their keep. If it saved you time: [$1 unlimited day pass](https://buy.stripe.com/9B600k0q62XS23b8ka8Vi0g) · [$3 supporter](https://buy.stripe.com/6oU14ofl0fKEcHP0RI8Vi07). Self-hosting is free and it's one file of stdlib-only Python.

## Endpoints

| Endpoint | Example | Returns |
|---|---|---|
| `/slug?text=` | `/slug?text=Hello World!` | `{"slug":"hello-world"}` |
| `/ts?iso=` or `/ts?unix=` | `/ts?iso=2026-10-22T15:00:00Z` | both epoch↔ISO conversions |
| `/case?text=&to=camel\|snake\|kebab\|pascal` | `/case?text=foo bar&to=camel` | `{"result":"fooBar"}` |
| `/hash?text=&algo=sha256` | `/hash?text=hi` | `{"algo":"sha256","hex":"..."}` (md5, sha1, sha256, sha512) |
| `/b64?op=encode|decode&text=` | `/b64?op=encode&text=hi` | `{"result":"aGk="}` |
| `/uuid?n=5` | `/uuid?n=5` | list of fresh UUID v4 |
| `/health` | `/health` | `{"ok":true}` |

JSON docs for humans: `GET /`. Everything is idempotent GET, so you can bookmark a query.

```bash
curl -s "https://goals-chips-asia-curtis.trycloudflare.com/slug?text=Read%20me%20now"
```

## Self-host

```bash
python3 server.py          # serves :8082 (TCP) and /tmp/app.sock (unix)
```

Put it behind any reverse proxy, or expose 8082 directly. No dependencies, no config files. Linux (uses a unix socket; set `SOCK` env to change path).

## Privacy

Minimal request logging (method, path, status — no IPs, no identifiers). That's the whole story.

## License

MIT.
