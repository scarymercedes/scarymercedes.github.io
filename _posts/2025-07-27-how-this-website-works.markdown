---
layout: post
title:  "How this website works"
date:   2025-07-27 17:08:36 +0000
categories: it
mermaid: true
---

I'm going to tell you about how I put this blog together - how it's hosted, how it's built, and why I picked the tools I did.

First off: the source for this website, as well as its deployment pipeline and development environment, are all in a [GitHub repository](https://github.com/scarymercedes/scarymercedes.github.io). Feel free to check it out.

# The web stack

This is a static website - that is, the contents of the website are fully rendered as HTML/JS/CSS files, and there's no backend server rendering the pages for you on the fly. (Perhaps you're wondering if "static website" is a fancy way of saying ["how all websites worked before CGI"](https://en.wikipedia.org/wiki/Common_Gateway_Interface). You'd be right.) 

I made this decision very early on, because static websites are incredibly easy to host; I don't need any meaningful compute, it scales to the size of a global CDN, and there's little to no attack surface for anyone to do something nefarious to it. You can run a decent static website for pennies or, with some compromises, free.

For comparison, a blog powered by a dynamic CMS - say, Wordpress or Django - would entail running a database to store the site's contents, a web server to respond to user queries and render the page, and perhaps a caching layer to alleviate stress on whatever server I ran this on. These would all have various APIs that I'd need to secure and monitor in case somebody decided to do something nasty.

Just because I don't have a traditional CMS, however, doesn't mean I have to fashion every page here by hand. (Setting aside the tedium of doing that, a frontend developer is something I am not). Thankfully, there's a rich ecosystem of headless, static CMS software that ingests markdown and frontmatter and spits out a very nice-looking blog as static files. The disadvantage of this is that I need to rebuild and republish my site every time I edit an article, but as I'll get into later, that's easy to automate; and the bonus of having everything in code is that Git can function as my version control system for my content, as well as my website.

I chose [Jekyll](https://jekyllrb.com/) as my CMS of choice, and as of right now, I'm running the default "minima" theme that ships with it. I picked it because it's familiar to me, super simple, widely adopted, and I'm more comfortable with Ruby than server-side JavaScript (sorry, [GatsbyJS](https://www.gatsbyjs.com/), I know you're the most versatile). All of my writing is in Markdown, so it won't be a big deal to change frameworks later.

Using Jekyll is pretty easy; you install some gems (it's Ruby!), tool around with a config file, maybe override some HTML for your headers and footers, and start writing markdown. When you're ready to spit out a page you can run `bundle exec jekyll build` (did I mention it's Ruby?) and if you'd like a live preview, `bundle exec jekyll serve` plugs a little webserver into localhost so you can view it in your browser. Adding the `--livereload` argument lets said webserver establish a websockets connection to your browser and push updates to it as soon as you save a file, which is also nice. 

Once it's rendered your static site into the `_site` folder, you can upload it to wherever. Before I get to that, though, I want to talk about how I keep track of all this.

## My development environment

As I mentioned, I need Ruby and some dependencies in order for this to run. Whenever I have a coding project that involves dependencies, I do one of two things:

- Cringe and try to remember how to use a runtime version manager ([rbenv in this case](https://github.com/rbenv/rbenv)), since there's no way I won't have another project going on that needs a different version of Ruby. I would then resign myself to my shell profile turning into an illegible mess. Oh, and hope I don't switch computers.
- Throw together a [dev container](https://containers.dev/) and be confident my code will run the same, every time, on anything with a container runtime and Git.


Stand by for a tangent, because I *love* dev containers.
dev container is an outgrowth of this cool little thing Visual Studio Code can do called [remote development](https://code.visualstudio.com/docs/remote/remote-overview), where it can basically split itself up into a two-tier application, with the GUI living on your computer and the backend existing... somewhere else. 

Initially that "somewhere else" was a remote machine via SSH (nice for if you need to do builds or run dependencies that may work on a Linux server but not your computer, or if you have different servers tailored for different projects, or if your laptop is a toaster). Then [Windows Subsystem for Linux](https://learn.microsoft.com/en-us/windows/wsl/install) became an option, turning Windows into a viable Linux desktop manager for those in the know. Finally, there's dev containers; VS Code can inject its runtime into a running OCI container image, which you can define and customise however you'd like via the dev container spec (which, for some infurating reason, has only really been adopted by Microsoft). All you need is a `dev container.json` and, if you want your own, a `Dockerfile`. In addition to the runtime environment, you can also include your IDE extensions and settings.

This is ideal; I can totally lose my computer, and have all my work back up and running within minutes of getting a new one. All I need is Git (to check out the repository), VS Code (to open it), and a container runtime (Docker for most, Rancher for some, Podman for me because I'm a contrarian). Windows, Linux, and MacOS can comfortably run Linux containers (either natively or via virtualization). This is *amazing* for projects where you're collaborating with a team; it helps for, say, onboarding a new colleague onto a project without having them spend all day installing prerequisites.

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


# The "server" "stack"

## My deployment pipeline