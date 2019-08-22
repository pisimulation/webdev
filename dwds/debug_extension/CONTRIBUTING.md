## Building

- Build with dart2js:

```
pub run build_runner build web -o build -r
```


## Deployment

- Update the version number in `web/manifest.json`.
- Zip `web/manifest.json`, `web/background.js`, and `dart.png`.
- Upload the `.zip` to the Chrome Web Store.