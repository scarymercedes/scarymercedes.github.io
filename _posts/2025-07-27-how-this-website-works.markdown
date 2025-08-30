---
layout: post
title:  "How this website works"
date:   2025-08-27 17:08:36 +0000
categories: it
mermaid: true
---

I'm going to tell you about how I put this blog together - how it's hosted, how it's built, and why I picked the tools I did.

First off: the source for this website, as well as its deployment pipeline and development environment, are all in a [GitHub repository](https://github.com/scarymercedes/scarymercedes.github.io). Feel free to check it out.

# The web stack

This is a static website - that is, the contents of the website are fully rendered HTML/JS/CSS files, and there's no backend server creating the pages for you on the fly depending on what you do. (Perhaps you're wondering if "static website" is a fancy way of saying ["how all websites worked before CGI"](https://en.wikipedia.org/wiki/Common_Gateway_Interface). You'd be right.) 

I made this decision very early on, because static websites are incredibly easy to host; I don't need any meaningful compute, it scales to the size of a global CDN, and there's little to no attack surface for anyone to do something nefarious to. You can run a decent static website for pennies or, with some compromises, free.

For comparison, a blog powered by a dynamic CMS - say, Wordpress or Django - would entail running a database to store the site's contents, a web server to respond to user queries and render the page, and perhaps a caching layer to alleviate stress on whatever server I ran this on. These would all have various APIs that I'd need to secure and monitor in case somebody decided to do something nasty.

Just because I don't have a traditional CMS, however, doesn't mean I have to fashion every page here by hand. (Setting aside the tedium of doing that, a frontend developer is something I am not.) Thankfully, there's a rich ecosystem of headless, static CMS software that ingests markdown and frontmatter and spits out a very nice-looking blog as static files. The disadvantage of this is that I need to rebuild and republish my site every time I edit an article. As I'll get into later, that's easy to automate; and the bonus of having everything in code is that Git can function as my version control system for my content, as well as my website.

I chose [Jekyll](https://jekyllrb.com/) as my CMS of choice, and as of right now, I'm running the default "minima" theme that ships with it. I picked it because it's familiar to me, super simple, widely adopted, and I'm more comfortable with Ruby than server-side JavaScript (sorry, [GatsbyJS](https://www.gatsbyjs.com/), I know you're the most versatile). All of my actual content (like this post) is in markdown, so it won't be a big deal to change frameworks later.

Using Jekyll is pretty easy; you install some gems (it's Ruby!), tool around with a config file, maybe override some HTML for your headers and footers, and start writing markdown. When you're ready to spit out a page you can run `bundle exec jekyll build` (did I mention it's Ruby?) and if you'd like a live preview, `bundle exec jekyll serve` plugs a little webserver into localhost so you can view it in your browser. Adding the `--livereload` argument lets said webserver establish a websockets connection to your browser and push updates to it as soon as you save a file, which is also nice. 

Once it's rendered your static site into the `_site` folder, you can upload it to wherever. Before I get to that, though, I want to talk about how I keep track of all this.

## My development environment

As I mentioned, I need Ruby and some dependencies in order for this to run. Whenever I have a coding project that involves dependencies, I do one of two things:

- Cringe and try to remember how to use a runtime version manager ([rbenv in this case](https://github.com/rbenv/rbenv)), since there's no way I won't have another project going on that needs a different version of Ruby. I would then resign myself to turning my shell profile into an illegible mess. Oh, and hope I don't switch computers.
- Throw together a [dev container](https://containers.dev/) and rest easy knowing my code will run the same, every time, on anything with a container runtime.

Stand by for a tangent, because I *love* dev containers.
dev container is an outgrowth of this cool little thing Visual Studio Code can do called [remote development](https://code.visualstudio.com/docs/remote/remote-overview), where it can basically split itself up into a two-tier application, with the GUI living on your computer and the backend (and the code it's editing) existing... somewhere else. 

Initially that "somewhere else" was a remote machine via SSH (nice for if you need to do builds or run dependencies that may work on a Linux server but not your computer, or if you have different servers tailored for different projects, or if your laptop is a toaster). Then [Windows Subsystem for Linux](https://learn.microsoft.com/en-us/windows/wsl/install) became an option, turning Windows into a viable Linux desktop manager for those in the know. Finally, there's dev containers; VS Code can inject its runtime into a running OCI container image, which you can define and customise however you'd like via the dev container spec (which, for some infuriating reason, has only really been adopted by Microsoft). All you need is a `devcontainer.json` and, if you want to customize the runtime environment, a `Dockerfile`. In addition to the runtime environment, you can also include your IDE extensions and settings.

This is ideal; I can lose my computer, and have my development environment back up and running within minutes of getting a new one. All I need is Git (to check out the repository), VS Code (to open it), and a container runtime (Docker for most, Rancher for some, Podman for me because I'm a contrarian). Windows, Linux, and MacOS can comfortably run Linux containers (either natively or via virtualization). This is *amazing* for projects where you're collaborating with a team; it helps for, say, onboarding a new colleague onto a project without having them spend all day installing prerequisites.

The dev container standard is also the lynchpin of the fourth VS Code remote development target, [Codespaces](https://github.com/features/codespaces); all the advantages of dev containers, but *also* good if your laptop is a toaster. Is it the year of desktop Linux or the year of the thin client? Take your pick.

Anyhow, dev containers. Here's a diagram.

<div class="mermaid">
---
config:
  treemap:
    showValues: false
---
treemap-beta "Dev"
"Dev Environment"
      "My laptop"
            "VS Code"
                  "Git repository": 50
                  "dev container"
                        "Ruby, Bundle, gems, extensions, etc": 100
</div>

Yes, that's mermaid.js up there. Huge thanks to [this blog post by Amr Abdel-Motaleb](https://amr-bash.github.io/docs/jekyll-diagram-with-mermaid/) for providing guidance on how to marry the corner cases of Jekyll, mermaid.js, and GitHub Pages.

If you'd like to know more, [look at my code](https://github.com/scarymercedes/scarymercedes.github.io/tree/main/.devcontainer). `devcontainer.json` tells the IDE what to do, including running in the Dockerfile, which includes all of my dependencies.

# The "server" "stack"

As I mentioned above, you can run a static site for cheap or free if you're willing to make some compromises. For example, if you don't mind your source code being public (which, being a static website, it already is), and you [abide by GitHub's terms of service and utilization limits](https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits), GitHub will gladly host your rendered content for the world to see, just like they do your code, free of charge. [Yes, I'm talking about GitHub Pages.](https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages) If you're looking to divest from a subsidiary of the world's largest software company, worry not; [GitLab has a similar offering.](https://docs.gitlab.com/user/project/pages/introduction/)

Important caveat: your repository name needs to end in `.github.io`. I forget to do this constantly.

You might be browsing this page via `martin.bonica.org`, not `scarymercedes.github.io`. GitHub Pages [supports custom domains](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site), and it will [even handle generating valid SSL certificates for you](https://docs.github.com/en/pages/getting-started-with-github-pages/securing-your-github-pages-site-with-https). Well, it asks [Let's Encrypt](https://letsencrypt.org/how-it-works/) to do it, but that's good enough for me.

The `bonica.org` hosted zone lives in [Amazon Route 53](https://aws.amazon.com/route53/), my longtime DNS service of choice and, depending on who you ask, [the best database service AWS has to offer](https://www.lastweekinaws.com/blog/route-53-amazons-premier-database/). In order to set up valid SSL for this page at `martin.bonica.org`, all I had to do was create a TXT record containing a challenge value (so GitHub Pages can prove to Let's Encrypt that it's acting on my domain's behalf), and a simple CNAME pointing `martin.bonica.org` at `scarymercedes.github.io`.

That was a lot, so here's another diagram.

<div class="mermaid">
flowchart TD
    A[bonica.org hosted zone in Route53] -->|Challenge TXT record| B(GitHub Pages Let's Encrypt Client)
    B -->|Certificate request| C[Let's Encrypt]
    C -->|martin.bonica.org Certificate| B
    A -->|martin.bonica.org A record| D[GitHub Pages scarymercedes.github.io]
</div>

One day, if I start to run into bandwidth issues, I might explore putting a CDN like [CloudFlare's free-tier offering](https://www.cloudflare.com/plans/free/) between my DNS and GitHub Pages. That would offer me an extra level of caching and bot/DDoS protection, although one would hope GitHub would be on top of that already. At that point, though, I might just start uploading my rendered page to [CloudFlare object storage](https://www.cloudflare.com/developer-platform/products/r2/) too and take GitHub Pages out of the mix entirely. Or AWS CloudFront and S3. Or Azure Front Door and Storage. Or... you get the point.



## My deployment pipeline

There are two ways GitHub Pages can publish a page. The "classic" way is to just check your static content into a branch, and tell GitHub (via repository settings) to publish a page at that branch. Immediately, that content will be served up at the default GitHub Pages URL; so, since my repository is `scarymercedes.github.io`, you can go to `https://scarymercedes.github.io`.

In addition to publishing the contents of a branch, [you can also upload a fully rendered archive to GitHub.](https://github.com/scarymercedes/scarymercedes.github.io/tree/main/.devcontainer) This by itself isn't incredibly useful, but it is the core of the other way to publish a GitHub Page; the [GitHub Actions source](https://github.com/scarymercedes/scarymercedes.github.io/tree/main/.devcontainer). GitHub Actions is GitHub's built-in CI/CD runner service, which gives you a decent amount of minutes and resources even at the free tier. Think of it as your own CircleCI, or Jenkins; you can configure GitHub Actions to run some code to test or deploy your application whenever you do something like open a pull request, or merge it. There's a rich ecosystem of open-source, shared GitHub Actions "Actions" (yes, Actions actions... doesn't have the same ring as [CircleCI Orbs](https://circleci.com/orbs/)) that can make your workflows more composable and repeatable.

[This is what I do.](https://github.com/scarymercedes/scarymercedes.github.io/blob/main/.github/workflows/github-pages.yaml) As you can see, I'm using some premade actions (set up Ruby, publish Jekyll, upload to GitHub) to build and upload the latest version of my site as soon as I merge to the main branch.

Yes, I use good branch hygiene and protect my main branch. Otherwise I might bypass the [spellcheck action](https://github.com/scarymercedes/scarymercedes.github.io/blob/main/.github/workflows/spellcheck.yaml) that will run when I open a pull request, and won't let me merge if I have spelling errors.

Here's one last diagram.

<div class="mermaid">
flowchart TD
    A[New content] -->|commit| B(Branch for new content)
    B --> C{Pull request to main}
    C -->|Upon PR creation| D[Spellcheck action]
    D -->|Block merge if fail| C
    C -->|Merge| E[Main branch]
    E -->|Trigger upon pushes to main| F[Deploy to Pages GitHub Action]
    F -->|Build ruby, render Jekyll site, upload to page| G[scarymercedes.github.io]
</div>

# In conclusion...

I just think it's great that I didn't have to pay for any of the infrastructure underpinning this website. Thanks to the proliferation of caching points-of-presence, ephemeral workloads on cheap cloud compute, and the incredible work of Let's Encrypt, it's easier than ever to deploy and host static content - and for not much more, you can break through the limitations of GitHub's free tier and host on one of the big public clouds using their various serverless compute/object storage/CDN/certificate management solutions. One day, I look forward to doing that so I can blog about it.