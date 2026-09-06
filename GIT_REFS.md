# Git Reference

## Template Repo (upstream)
**GitHub:** https://github.com/crummo/folio-template
**Pages (dev preview):** https://crummo.github.io/folio-template

## Downstream Sites
Each site has its own repo. The template is set as `upstream` in each one.

| Site | GitHub Repo | Live URL |
|------|-------------|----------|
| cameronrumford.com | https://github.com/crummo/cameronrumford.com | https://www.cameronrumford.com |
| katrinarumford.com | https://github.com/crummo/katrinarumford.com | https://www.katrinarumford.com |
| slowdustpost.com | https://github.com/crummo/slowdustpost.com | https://www.slowdustpost.com |
| slowduststudio.com | https://github.com/crummo/folio-template | https://www.slowduststudio.com |

> **Note:** Repo names above may not be exact — run `git remote -v` inside each site folder to confirm.

---

## Syncing Template Updates into a Site

```bash
cd /path/to/site-repo
git fetch upstream
git checkout upstream/main -- index.html studio.html dashboard.html 404.html 08_hanger.svg update.sh
git commit -m "sync: update template from upstream"
git push
```

`site.json`, `projects.json`, `images/`, `gallery/`, `thumbs/` are gitignored on the template side — syncs never touch site data.

## Setting Up a New Site from the Template

```bash
# 1. Create a new repo on GitHub (e.g. crummo/new-site), then:
git clone https://github.com/crummo/new-site.git
cd new-site
git remote add upstream https://github.com/crummo/folio-template.git
git fetch upstream
git checkout upstream/main -- index.html studio.html dashboard.html 404.html .nojekyll 08_hanger.svg
git commit -m "init: pull template from upstream"
git push
```

## Push Workaround (Cowork sandbox lock files)

If `git push` fails with "Another git process seems to be running":

```bash
rm -f .git/index.lock .git/HEAD.lock .git/refs/heads/main.lock
```

Or clone fresh in /tmp and push from there:

```bash
TOKEN=$(cat _internal/.github_token.txt | tr -d '[:space:]')
cd /tmp && rm -rf site-push
git clone https://${TOKEN}@github.com/crummo/REPO_NAME.git site-push
cp index.html studio.html site-push/
cd site-push && git add . && git commit -m "..." && git push
```
