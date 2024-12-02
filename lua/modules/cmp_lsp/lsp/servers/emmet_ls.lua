-- https://github.com/pedro757/emmet
-- npm i -g ls_emmet

-- luacheck: ignore
-- local cmd = {}

-- if HOST.is_win then
--    cmd = { 'pwsh', '-c', 'ls_emmet', '--stdio' }
-- else
--    cmd = { 'ls_emmet', '--stdio' }
-- end

local M = {}

-- M.cmd = cmd
M.filetypes = {
   'html',
   'css',
   'scss',
   'javascript',
   'javascriptreact',
   'typescript',
   'typescriptreact',
   'haml',
   'xml',
   'xsl',
   'pug',
   'slim',
   'sass',
   'stylus',
   'less',
   'sss',
   'hbs',
   'handlebars',
   'eruby',
   'svelte',
   'vue',
}
--[[
/** A string for one level indent */
'output.indent': string;

/**
* A string for base indent, e.g. context indentation which will be added
* for every generated line
*/
'output.baseIndent': string;

/** A string to use as a new line */
'output.newline': string;

/** Tag case: lower, upper or '' (keep as-is) */
'output.tagCase': StringCase;

/** Attribute name case: lower, upper or '' (keep as-is) */
'output.attributeCase': StringCase;

/** Attribute value quotes: 'single' or 'double' */
'output.attributeQuotes': 'single' | 'double';

/** Enable output formatting (indentation and line breaks) */
'output.format': boolean;

/** When enabled, automatically adds inner line breaks for leaf (e.g. without children) nodes */
'output.formatLeafNode': boolean;

/** A list of tag names that should not get inner indentation */
'output.formatSkip': string[];

/** A list of tag names that should *always* get inner indentation. */
'output.formatForce': string[];

/**
* How many inline sibling elements should force line break for each tag.
* Set to `0` to output all inline elements without formatting.
* Set to `1` to output all inline elements with formatting (same as block-level).
*/
'output.inlineBreak': number;

/**
* Produce compact notation of boolean attributes: attributes which doesn’t have value.
* With this option enabled, outputs `<div contenteditable>` instead of
* `<div contenteditable="contenteditable">`
*/
'output.compactBoolean': boolean;

/** A list of boolean attributes */
'output.booleanAttributes': string[];

/** Reverses attribute merging directions when resolving snippets */
'output.reverseAttributes': boolean;

/** Style of self-closing tags: html (`<br>`), xml (`<br/>`) or xhtml (`<br />`) */
'output.selfClosingStyle': 'html' | 'xml' | 'xhtml';

/**
* A function that takes field index and optional placeholder and returns
* a string field (tabstop) for host editor. For example, a TextMate-style
* field is `$index` or `${index:placeholder}`
* @param index Field index
* @param placeholder Field placeholder (default value), if any
* @param offset Current character offset from the beginning of generated content
* @param line Current line of generated output
* @param column Current column in line
*/
'output.field': FieldOutput;

/**
* A function for processing text chunk passed to `OutputStream`.
* May be used by editor for escaping characters, if necessary
*/
'output.text': TextOutput;

////////////////////
// Markup options //
////////////////////

/**
* Automatically update value of <a> element's href attribute
* if inserting URL or email
*/
'markup.href': boolean;

/**
* Attribute name mapping. Can be used to change attribute names for output.
* For example, `class` -> `className` in JSX. If a key ends with `*`, this
* value will be used for multi-attributes: currentry, it’s a `class` and `id`
* since `multiple` marker is added for shorthand attributes only.
* Example: `{ "class*": "styleName" }`
*/
'markup.attributes'?: Record<string, string>;

/**
* Prefixes for attribute values.
* If specified, a value is treated as prefix for object notation and
* automatically converts attribute value into expression if `jsx` is enabled.
* Same as in `markup.attributes` option, a `*` can be used.
*/
'markup.valuePrefix'?: Record<string, string>;

////////////////////////////////
// Element commenting options //
////////////////////////////////

/**
* Enable/disable element commenting: generate comments before open and/or
* after close tag
*/
'comment.enabled': boolean;

/**
* Attributes that should trigger node commenting on specific node,
* if commenting is enabled
*/
'comment.trigger': string[];

/**
* Template string for comment to be placed *before* opening tag
*/
'comment.before': string;

/**
* Template string for comment to be placed *after* closing tag.
* Example: `\n<!-- /[#ID][.CLASS] -->`
*/
'comment.after': string;

/////////////////
// BEM options //
/////////////////

/** Enable/disable BEM addon */
'bem.enabled': boolean;

/** A string for separating elements in output class */
'bem.element': string;

/** A string for separating modifiers in output class */
'bem.modifier': string;

/////////////////
// JSX options //
/////////////////

/** Enable/disable JSX addon */
'jsx.enabled': boolean;

////////////////////////
// Stylesheet options //
////////////////////////

/** List of globally available keywords for properties */
'stylesheet.keywords': string[];

/**
* List of unitless properties, e.g. properties where numeric values without
* explicit unit will be outputted as is, without default value
*/
'stylesheet.unitless': string[];

/** Use short hex notation where possible, e.g. `#000` instead of `#000000` */
'stylesheet.shortHex': boolean;

/** A string between property name and value */
'stylesheet.between': string;

/** A string after property value */
'stylesheet.after': string;

/** A unit suffix to output by default after integer values, 'px' by default */
'stylesheet.intUnit': string;
--]]

M.init_options = {
   html = {
      options = {
         -- For possible options, see: https://github.com/emmetio/emmet/blob/master/src/config.ts#L79-L267
         ['bem.enabled'] = true,
      },
   },
}

return M
