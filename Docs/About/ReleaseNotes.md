# Release Notes

All of our release notes for each release of the framework are documented here.

<hr/>

## Version X.X.X (YYYY-MM-DD)
* Thing changed.
  And the change was awesome.
* Another thing changed.

### Not backwards compatible

This update is not backwards compatible.

#### Details
Yeah. You heard me. Learn to upgrade noobs.

## Version 1.0 (2018-08-03)

### Major Additions to Version 1.0

#### Internal Refactor of Pages, Files, and Navigation

Internal handling of pages, files and navigation has been completely refactored.
The changes included in the refactor are summarized below.

* Support for hidden pages. All Markdown pages are now included in the build
  regardless of whether they are included in the navigation configuration
  (#699).
* The navigation can now include links to external sites (#989 #1373 & #1406).
* Page data (including titles) is properly determined for all pages before any
  page is rendered (#1347).
* Automatically populated navigation now sorts index pages to the top. In other
  words, The index page will be listed as the first child of a directory, while
  all other documents are sorted alphanumerically by file name after the index
  page (#73 & #1042).
* A `README.md` file is now treated as an index file within a directory and
  will be rendered to `index.html` (#608).
* The URLs for all files are computed once and stored in a files collection.
  This ensures all internal links are always computed correctly regardless of
  the configuration. This also allows all internal links to be validated, not
  just links to other Markdown pages. (#842 & #872).
* A new [url] template filter smartly ensures all URLs are relative to the
  current page (#1526).
* An [on_files] plugin event has been added, which could be used to include
  files not in the `docs_dir`, exclude files, redefine page URLs (i.e.
  implement extensionless URLs), or to manipulate files in various other ways.

  [on_files]: ../user-guide/plugins.md#on_files

##### Backward Incompatible Changes

As part of the internal refactor, a number of backward incompatible changes have
been introduced, which are summarized below.

###### URLS have changed when `use_directory_urls` is `False`

Previously, all Markdown pages would be have their filenames altered to be index
pages regardless of how the [use_directory_urls] setting was configured.
However, the path munging is only needed when `use_directory_urls` is set to
`True` (the default). The path mungling no longer happens when
`use_directory_urls` is set to `False`, which will result in different URLs for
all pages that were not already index files. As this behavior only effects a
non-default configuration, and the most common user-case for setting the option
to `False` is for local file system (`file://`) browsing, its not likely to
effect most users. However, if you have `use_directory_urls` set to `False`
for a MkDocs site hosted on a web server, most of your URLs will now be broken.
As you can see below, the new URLs are much more sensible.

| Markdown file   | Old URL              | New URL        |
| --------------- | -------------------- | -------------- |
| `index.md`      | `index.html`         | `index.html`   |
| `foo.md`        | `foo/index.html`     | `foo.html`     |
| `foo/bar.md`    | `foo/bar/index.html` | `foo/bar.html` |

Note that there has been no change to URLs or file paths when
`use_directory_urls` is set to `True` (the default), except that MkDocs more
consistently includes an ending slash on all internally generated URLs.

[use_directory_urls]: ../user-guide/configuration.md#use_directory_urls

###### The `pages` configuration setting has been renamed to `nav`

The `pages` configuration setting is deprecated and will issue a warning if set
in the configuration file. The setting has been renamed `nav`. To update your
configuration, simply rename the setting to `nav`. In other words, if your
configuration looked like this:

```yaml
pages:
    - Home: index.md
    - User Guide: user-guide.md
```

Simply edit the configuration as follows:

```yaml
nav:
    - Home: index.md
    - User Guide: user-guide.md
```

In the current release, any configuration which includes a `pages` setting, but
no `nav` setting, the `pages` configuration will be copied to `nav` and a
warning will be issued. However, in a future release, that may no longer happen.
If both `pages` and `nav` are defined, the `pages` setting will be ignored.

###### Template variables and `base_url`

In previous versions of MkDocs some URLs expected the [base_url] template
variable to be prepended to the URL and others did not. That inconsistency has
been removed in that no URLs are modified before being added to the template
context.

For example, a theme template might have previously included a link to
the `site_name` as:

```django
<a href="{{ nav.homepage.url }}">{{ config.site_name }}</a>
```

And MkDocs would magically return a URL for the homepage which was relative to
the current page. That "magic" has been removed and the [url] template filter
should be used:

```django
<a href="{{ nav.homepage.url|url }}">{{ config.site_name }}</a>
```

This change applies to any navigation items and pages, as well as the
`page.next_page` and `page.previous_page` attributes. For the time being, the
`extra_javascript` and `extra_css` variables continue to work as previously
(without the `url` template filter), but they have been deprecated and the
corresponding configuration values (`config.extra_javascript` and
`config.extra_css` respectively) should be used with the filter instead.

```django
{% for path in config['extra_css'] %}
    <link href="{{ path|url }}" rel="stylesheet">
{% endfor %}
```

Note that navigation can now include links to external sites. Obviously, the
`base_url` should not be prepended to these items. However, the `url` template
filter is smart enough to recognize the URL is absolute and does not alter it.
Therefore, all navigation items can be passed to the filter and only those that
need to will be altered.

```django
{% for nav_item in nav %}
    <a href="{{ nav_item.url|url }}">{{ nav_item.title }}</a>
{% endfor %}
```

[base_url]: ../user-guide/custom-themes.md#base_url
[url]: ../user-guide/custom-themes.md#url

#### Path Based Settings are Relative to Configuration File (#543)

Previously any relative paths in the various configuration options were
resolved relative to the current working directory. They are now resolved
relative to the configuration file. As the documentation has always encouraged
running the various MkDocs commands from the directory that contains the
configuration file (project root), this change will not affect most users.
However, it will make it much easier to implement automated builds or otherwise
run commands from a location other than the project root.

Simply use the `-f/--config-file` option and point it at the configuration file:

```sh
mkdocs build --config-file /path/to/my/config/file.yml
```

As previously, if no file is specified, MkDocs looks for a file named
`mkdocs.yml` in the current working directory.

#### Added support for YAML Meta-Data (#1542)

Previously, MkDocs only supported MultiMarkdown style meta-data, which does not
recognize different data types and is rather limited. MkDocs now also supports
YAML style meta-data in Markdown documents. MkDocs relies on the the presence or
absence of the deliminators (`---` or `...`) to determine whether YAML style
meta-data or MultiMarkdown style meta-data is being used.

Previously MkDocs would recognize MultiMarkdown style meta-data between the
deliminators. Now, if the deliminators are detected, but the content between the
deliminators is not valid YAML meta-data, MkDocs does not attempt to parse the
content as MultiMarkdown style meta-data. Therefore, MultiMarkdowns style
meta-data must not include the deliminators. See the [MultiMarkdown style
meta-data documentation] for details.

Prior to version 0.17, MkDocs returned all meta-data values as a list of strings
(even a single line would return a list of one string). In version 0.17, that
behavior was changed to return each value as a single string (multiple lines
were joined), which some users found limiting (see #1471). That behavior
continues for MultiMarkdown style meta-data in the current version. However,
YAML style meta-data supports the full range of "safe" YAML data types.
Therefore, it is recommended that any complex meta-data make use of the YAML
style (see the [YAML style meta-data documentation] for details). In fact, a
future version of MkDocs may deprecate support for MultiMarkdown style
meta-data.

[MultiMarkdown style meta-data documentation]: ../user-guide/writing-your-docs.md#multimarkdown-style-meta-data
[YAML style meta-data documentation]: ../user-guide/writing-your-docs.md#yaml-style-meta-data

#### Refactor Search Plugin

The search plugin has been completely refactored to include support for the
following features:

* Use a web worker in the browser with a fallback (#1396).
* Optionally pre-build search index locally (#859 & #1061).
* Upgrade to lunr.js 2.x (#1319).
* Support search in languages other than English (#826).
* Allow the user to define the word separators (#867).
* Only run searches for queries of length > 2 (#1127).
* Remove dependency on require.js (#1218).
* Compress the search index (#1128).

Users can review the [configuration options][search config] available and theme
authors should review how [search and themes] interact.

[search config]: ../user-guide/configuration.md#search
[search and themes]: ../user-guide/custom-themes.md#search_and_themes

#### `theme_dir` Configuration Option fully Deprecated

As of version 0.17, the [custom_dir] option replaced the deprecated `theme_dir`
option. If users had set the `theme_dir` option, MkDocs version 0.17 copied the
value to the `theme.custom_dir` option and a warning was issued. As of version
1.0, the value is no longer copied and an error is raised.

### Other Changes and Additions to Version 1.0

* Keyboard shortcuts changed to not conflict with commonly used accessibility
  shortcuts (#1502.)
* User friendly YAML parse errors (#1543).
* Officially support Python 3.7.
* A missing theme configuration file now raises an error.
* Empty `extra_css` and `extra_javascript` settings no longer raise a warning.
* Add highlight.js configuration settings to built-in themes (#1284).
* Close search modal when result is selected (#1527).
* Add a level attribute to AnchorLinks (#1272).
* Add MkDocs version check to gh-deploy script (#640).
* Improve Markdown extension error messages. (#782).
* Drop official support for Python 3.3 and set `tornado>=5.0` (#1427).
* Add support for GitLab edit links (#1435).
* Link to GitHub issues from release notes (#644).
* Expand {sha} and {version} in gh-deploy commit message (#1410).
* Compress `sitemap.xml` (#1130).
* Defer loading JS scripts (#1380).
* Add a title attribute to the search input (#1379).
* Update RespondJS to latest version (#1398).
* Always load Google Analytics over HTTPS (#1397).
* Improve scrolling frame rate (#1394).
* Provide more version info. (#1393).
* Refactor `writing-your-docs.md` (#1392).
* Workaround Safari bug when zooming to &lt; 100% (#1389).
* Remove addition of `clicky` class to body and animations. (#1387).
* Prevent search plugin from reinjecting `extra_javascript` files (#1388).
* Refactor `copy_media_files` util function for more flexibility (#1370).
* Remove PyPI Deployment Docs (#1360).
* Update links to Python-Markdown library (#1360).
* Document how to generate manpages for MkDocs commands (#686).