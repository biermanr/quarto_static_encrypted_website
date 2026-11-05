# Encrypted static website through GitHub Pages

Have you ever wanted to make a website which has simple password protection
but you don't want to set up a server, user accounts, and a database?

Fortunately, other people have thought of this problem and created tools like
[StatiCrypt](https://github.com/robinmoisson/staticrypt), which make it possible
to have a private static website anywhere, including GitHub or AWS S3. The way it
works is that the HTML pages ARE public, but they're **encrypted**. So anyone can
visit or download your website, but without the shared-password it won't mean
anything to them.

The goal of this repo is to show how to create a password-protected static
website written in [Quarto](https://quarto.org), encrypted with
[StatiCrypt](https://github.com/robinmoisson/staticrypt), and published to
GitHub Pages.  If you don't need Quarto,
[a-nau/password-protected-website-template](https://github.com/a-nau/password-protected-website-template)
is a nice template with a lot of overlap with this one.

Try it out! Visit the website and use password "BBQ" to log in:
https://biermanr.github.io/static_encrypted_website/

## Setup your own

1. **Make your own private copy.** Click **Use this template → Create a new
   repository** and choose **Private**. (Don't fork: a fork of a public repo
   is always public, which would publish your unencrypted `.qmd` sources.)

2. **Enable Pages.** Go to *Settings → Pages → Build and deployment →
   Source* and choose **GitHub Actions**.

3. **Make it yours.** Change `--password BBQ` in [`build.sh`](build.sh). You
   can do this directly in the browser.

4. Commit and push to `main`. The site is published by default to
   `https://<user>.github.io/<repo-name>/` 

## Tools we'll be using

* **[Quarto](https://quarto.org)**
  * Allows you to write markdown files and *render* them into HTML
  * Not required, you could make your HTML files however you want!

* **[StatiCrypt](https://github.com/robinmoisson/staticrypt)**
  * Encrypts your HTML files

* GitHub Actions CI
  * Runs the Quarto then StatiCrypt steps and publishes the GitHub Pages website
  * We'll set this up to run on each push to the main branch


## Workflow explanation

Inside of the `website/` folder of this repo you'll see files like `index.qmd`
and `menu.qmd` etc. These are the files with the website content that
we'll actually be editing.

Then when we're happy, we can run `quarto render website/` (you'll need to
install Quarto). This creates a new folder `website/unencrypted_site` where
your HTML pages live. Open `website/unencrypted_site/index.html` in your web
browser to see what the website will look like. It's not encrypted yet, we've
only done the first step.

Then we need to run StatiCrypt (requires Node.js) to encrypt the HTML files produced by Quarto:

```bash
npx --yes staticrypt@3.5.4 website/unencrypted_site/*.html \
  --directory website/encrypted_site \
  --password BBQ \
  --short \
  --config false
```

Notice that we're setting the encryption password here!

Otherwise this command is taking as input the HTML files from the unencrypted folder
and outputting them to a new encrypted folder.

Open `website/encrypted_site/index.html` in your web browser. You should be
forced to log in using the password **BBQ**.

<details>
<summary><b>What does StatiCrypt actually do to a page?</b></summary>

**Before:** `unencrypted_site/index.html` (174 bytes)

```html
<!DOCTYPE html>
<html>
  <head><title>Summer BBQ</title></head>
  <body>
    <h1>You're invited!</h1>
    <p>Saturday, July 17 at 4pm, 123 Example Lane</p>
  </body>
</html>
```

**After:** `encrypted_site/index.html` is mostly staticrypt portions:

```html
<!DOCTYPE html>
<html class="staticrypt-html">
    <head>
        <title>Protected Page</title>
        <!-- ... staticrypt styles for the login page ... -->
    </head>
    <body class="staticrypt-body">
        <!-- ... staticrypt password box ... -->
        <script>
            // ... HERE'S WHERE THE ORIGINAL HTML GOT ENCRYPTED
            staticryptConfig = {
                "staticryptEncryptedMsgUniqueVariableName": "12234bf5e4d8...9c916583",
                // ...
            };
            // ... code that shows the login form or decrypts the page ...
        </script>
    </body>
</html>
```

Your whole original page is inside that `staticryptConfg` block,
even if you had embedded images. This encrypted string is all
someone would be able to see if they downloaded your page without the password.

Typing the password turns all of this back into the 174-byte page above, exactly!

</details>

## Actual workflow

In the Workflow explanation above, we explicitly listed all the steps and commands,
but the steps to rebuild the encrypted `.html` files after editing the `.qmd` files
is going to be the same every time so we can just put them into a convenience
script, [`build.sh`](build.sh):

```bash
sh build.sh   # render + encrypt into website/encrypted_site
```

Then open `website/encrypted_site/index.html` in your web browser to check
the result.

The GitHub Actions CI ([`.github/workflows/publish.yml`](.github/workflows/publish.yml))
runs this `sh build.sh` on every push to `main`, then publishes
`website/encrypted_site/` to GitHub Pages.

## Caveats

- **The password is the only protection.** Anyone can download the encrypted
  pages and try passwords offline. Use a long passphrase for anything important.
  This demo uses the `--short` parameter to StatiCrypt to use the `BBQ` password,
  but StatiCrypt recommends a password of at least 14 characters.
- **Page size.** Each page carries its own inlined copy of Bootstrap, the
  icon font and every image. That is about 1.6 MB of plaintext, or about
  1.9 MB per page over the wire after encryption. Resize photos before adding
  them.
- **Visible without the password:** the login page, the page file names, and
  the fact that the site exists.

## FAQ

<details>
<summary><b>Why would I want an encrypted static website?</b></summary>

<blockquote>

<details open>
<summary><b>Summer BBQ invitation</b> (this repo)</summary>

Let's say you are planning a party with 20 guests and need a way to
communicate details to them. You could just create an email and send it out
to everyone, even use BCC to avoid reply-all avalanches!  But then whenever
party details change you'll need to send out another email.

Instead you could create a website for the event. That way you send a single
email with the URL and say "please check the website for updates".  Maybe you
already have a GitHub account and are comfortable using GitHub Pages which is
free. That way you don't need a dedicated server, it's just a static website!

But you don't want this website to be completely public. Who knows what miscreants would
show up to the event! You also don't want the hassle of giving each guest their
own password. Instead you just want to share a single password for everyone like "BBQ".

</details>

<details>
<summary><b>Digital art portfolio</b></summary>

You're an illustrator applying for jobs or pitching to a few galleries. You
want to show your full portfolio, including unreleased pieces.
Emailing big image attachments is clunky,
and a public portfolio site would put the unreleased work out there for
anyone (and any AI scraper) to grab.

With an encrypted static site you share one link and one password with the
people you're pitching. Swap in new pieces whenever you like, and change the
password once the round of applications is over.

</details>

<details>
<summary><b>Family recipe book</b></summary>

Grandma's recipes are scattered across index cards, old emails and photos
in the family group chat. You want one place where the whole extended
family can look them up, and where you can keep adding new ones over the
years. But they come with family stories, names and photos of relatives
that you'd rather not put on the public internet. And some recipes are
family secrets!

</details>

</blockquote>

</details>

<details>
<summary><b>Why is private static hosting not trivial?</b></summary>

In all of the examples above you need a private GitHub repo to hide your source
files, and maybe you have a GitHub Pro account so that's not a problem.
Unfortunately getting a password-protected static website isn't trivial.

If your repo belongs to a GitHub Enterprise Cloud organization then you CAN
have a private GitHub Pages site which is gated through a GitHub login. But
you're probably not using GitHub Enterprise for a project like this, and not
everyone you're sharing with will have a GitHub account anyway.

</details>

<details>
<summary><b>Where are the images and CSS files?</b></summary>

If you look in `website/` you'll see an `images/` folder with graphics
for the BBQ party. But if you look in the folder `website/encrypted_site/`
you'll only see HTML files.

The reason for this is that StatiCrypt only encrypts HTML files, and we
didn't want to upload our images to GitHub Pages because then anyone could
see them. Instead we can simply embed the images into the HTML as base64
strings by setting `embed-resources: true` in the `website/_quarto.yml` configuration
file. This makes the `unencrypted_site/*.html` files produced by `quarto render`
completely self-contained. So when these HTML files get encrypted by StatiCrypt
the embedded images, CSS, and JavaScript are also encrypted.

This works well so long as the images aren't large, otherwise the encoded HTML files
will be huge.

</details>

<details>
<summary><b>Can I use Quarto's built-in search?</b></summary>

No, not without compromising security.
Quarto's search box works by downloading `search.json`, an index that
contains the text of every page in plain text. The build only encrypts and
publishes the HTML pages, so `search.json` is never published.

We've turned off search in the `website/_quarto.yml` config file.

</details>

<details>
<summary><b>Do users need to enter the password for every page?</b></summary>

Only if they leave "Remember me" unticked. Every page is encrypted with the
same password, so after one login with "Remember me" ticked, the
key is saved in the browser's `localStorage` with no expiry date, and every
other page on the site opens automatically.

Note that each change and re-publishing of the website will require
everyone to login again. This can be avoided by passing a fixed `--salt` (any 32
hex characters, e.g. from `openssl rand -hex 16`) in `build.sh`.

</details>

<details>
<summary><b>How does logout work?</b></summary>

The **Logout** button in the navbar (set in `website/_quarto.yml`) links to
`index.html?staticrypt_logout`. When a page loads, StatiCrypt checks the URL
for `staticrypt_logout`. If it's there, StatiCrypt deletes the saved key
from the browser's `localStorage` and shows the login page.

</details>

<details>
<summary><b>Isn't it bad to hardcode the password in <code>build.sh</code>?</b></summary>

You're right, it's bad, but it's nice and explicit for this example.

As long as the repo stays private it's technically fine. But a password
committed to the repo can be read by anyone with access to the repo, stays
in the git history forever, and is exposed if the repo is ever made public.

For a real site, use a GitHub secret instead:

1. Remove `--password BBQ` from `build.sh`. StatiCrypt then reads
   the password from the `STATICRYPT_PASSWORD` environment variable.
2. Add a repository secret: *Settings → Secrets and variables → Actions →
   New repository secret*, named exactly `STATICRYPT_PASSWORD`.
3. Pass it to the build step in `.github/workflows/publish.yml`:

   ```yaml
   - name: Build and encrypt
     env:
       STATICRYPT_PASSWORD: ${{ secrets.STATICRYPT_PASSWORD }}
     run: sh build.sh
   ```

To build locally, set the variable when you run the script:

```bash
STATICRYPT_PASSWORD='your long passphrase' sh build.sh
```

</details>

## Contributing

Issues and pull requests are welcome, whether it's a bug fix, a clearer
explanation, or a question about how something works.

## 🤖 AI usage disclaimer 🤖

This repo was built with help from [Claude Code](https://claude.com/claude-code). I reviewed, tested and edited everything. I am responsible for the final product, good or bad.
