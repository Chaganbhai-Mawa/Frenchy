# Bonjourney website — deploy to Netlify

Static site, no build step. Three pages plus assets:

```
netlify-site/
├── index.html      ← landing page
├── privacy.html     ← privacy policy (link this URL in Play Console)
├── app-ads.txt      ← IAB app-ads.txt, live with the real AdMob publisher ID
├── netlify.toml      ← headers config (serves ads.txt as text/plain, security headers)
└── assets/          ← app icon + real screenshots, already sized for web
```

## Deploy (pick one — both take under 2 minutes)

### Option A: drag-and-drop (fastest, no account setup beyond signing in)

1. Go to https://app.netlify.com/drop
2. Drag the entire `netlify-site` folder onto the page.
3. Netlify assigns a random URL like `https://random-name-12345.netlify.app` — you can
   rename it for free in **Site settings → Change site name** (e.g. `bonjourney-app`, giving
   you `https://bonjourney-app.netlify.app`).

### Option B: Netlify CLI (better if you'll update the site often)

```bash
npm install -g netlify-cli
cd netlify-site
netlify deploy --prod
```
Follow the prompts to log in and create/select a site. Re-run `netlify deploy --prod`
any time you edit the files here to push an update.

### Option C: connect a Git repo (best for ongoing edits)

If you put this project on GitHub/GitLab, connect the repo in the Netlify dashboard
(**Add new site → Import an existing project**), set the **base directory** to
`netlify-site` and leave the build command empty (it's static HTML) — every push updates
the live site automatically.

## After deploying

1. Note your live URL (e.g. `https://bonjourney-app.netlify.app`).
2. Put `https://<your-site>/privacy.html` into Play Console → App content → Privacy policy
   (see `../store-listing/README.md` step 4).
3. Optional: add a custom domain in Netlify's **Domain settings** if you own one
   (bonjourney.app, mybonjourney.com, etc.) — Netlify provisions free HTTPS automatically.

## Editing later

- **Play Store link on the homepage**: once your app is live, replace the two
  `href="#" onclick="return false;"` buttons in `index.html` with your real Play Store URL
  (`https://play.google.com/store/apps/details?id=com.bonjourney.app`) and remove the
  `<span class="badge-soon">coming soon</span>` badge next to each.
- **app-ads.txt**: already live with the real AdMob publisher ID — see
  `../store-listing/admob-integration-checklist.md` for what's wired in.
- **Screenshots**: if you update the app's look, re-capture screenshots (see
  `../store-listing/screenshots/README.md`) and swap the files in `assets/`.
