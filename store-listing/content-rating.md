# Content rating questionnaire — guidance

Play Console → App content → Content ratings. This runs through the IARC (International
Age Rating Coalition) questionnaire. Bonjourney is a straightforward "everyone" case; answer
**No** to essentially every content category:

| Question | Answer | Why |
|---|---|---|
| Violence | No | None |
| Blood/gore | No | None |
| Sexual content / nudity | No | None |
| Profanity / crude humor | No | None |
| Controlled substances (alcohol/tobacco/drugs) references | No | None — some C1/C2 vocabulary units may mention real-world topics (e.g. news/editorial themes) but do not depict, promote, or instruct substance use |
| Gambling (simulated or real) | No | None |
| User-generated content | No | No chat, forums, or content sharing between users |
| Shares user location | No | No location access requested |
| Digital purchases | No | No IAP, no subscriptions (for this build) |
| Unrestricted internet access / web browser | Partial — declare the in-app WebView | Used only to embed curated YouTube lesson videos and open external links via the system browser as a fallback |

**Expected result**: PEGI 3 / ESRB Everyone / USK 0 — suitable for all ages, appropriate
for an education app.

The questionnaire has a section on ads — answer that the app **does show ads**, served by a
third-party network (Google AdMob). Configure AdMob's own ad content rating separately in
the AdMob console (App settings → Content settings) to keep it aligned — e.g. restrict to
"G"/family-friendly ad content given a language-learning app likely has some younger users.
