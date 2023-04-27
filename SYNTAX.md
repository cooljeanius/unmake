# SYNTAX

`unmake` follows a relatively stiff reading of the POSIX `make` standard. POSIX discipline helps to maintain a higher degree of portability for makefiles, across many different operating environments.

# EXAMPLE

makefile

```make
.PHONY: all

all:
	@echo "Hello World!"
```

Usage:

```console
$ make
Hello World!
```

## Notes

* The lowercase `makefile` filename has faster precedence order than `Makefile`.
* `.PHONY` marks logical targets like `all`, intended to re-run whenever the task is called for.
* The first non-special target with no prerequisites is the default target, conventionally named `all`.
* Minimal UNIX or Windows-specific arguments supplied to the `echo` command.
* No single quotes (`'`) string arguments, which may break in certain Windows environments.
* Optionally use `.SILENT:` instead of indivual `@` command markers, to silence all commands.

# POSIX

unmake targets POSIX 202x Issue 8, Draft 3.

https://www.opengroup.org/austin/

# CAVEATS

We do our best to catch many of the more obvious POSIX make mistakes, but some mistakes may continue to slip up nonetheless. For example:

* Accidents hiding inside macro expressions
* Accidents hiding inside command output
* Accidents hiding inside `include` chains
* Misuse of reserved target names
* Behavior during live `make` script execution
* GNU/BSD/etc. extensions beyond the POSIX standard
* Variance in make implementation adherence to the POSIX standard
* Clock and file system timestamp variance
* Files not named like `makefile` or `*.mk`
* Logic errors

make users are advised to generally familiarize with basic make usage, syntax, and semantics, in order to resolve problems faster.

## Line endings

The legacy line endings CRLF (`\r\n`) and CR (`\r`) are out of spec. make expects LF (`\n`).

In fact, the POSIX standard specifies that text files the LF line ending, as well as a final LF End Of Line (EOL) character at the end of any non-zero-byte text file.

### Fail

We briefly list some illustrative makefile contents expected to fail parsing.

```make
all:<CRLF>
	echo "Hello World!"
```

```make
all:<CR>
	echo "Hello World!"
```

### Pass

We briefly list some illustrate makefile contents expected to pass parsing.

```make
all:<LF>
	echo "Hello World!"<LF>
```

### Mitigation

* Note that recent editions of Notepad are LF-aware, but may continue to accidentally default to CRLF when creating new files. Use a more capable text editor, such as [emacs](https://www.gnu.org/software/emacs/), [nano](https://www.nano-editor.org/), [Notepad++](https://notepad-plus-plus.org/), [vim](https://www.vim.org/), [VSCode](https://code.visualstudio.com/), etc.
* Configure [EditorConfig](https://editorconfig.org/) and your text editor, to default most any non-Windows-centric text files to LF line endings and a final EOL.
* If necessary, relaunch the text editor and resave the file.
* Reset [git](https://git-scm.com/)'s configuration (both the git-config and gitattributes systems) to the default behavior, which tends to preserve file endings as written
* Apply [tofrodos](https://www.thefreecountry.com/tofrodos/index.shtml)'s `fromdos` utility on affected files

## Rule command indentation

make generally expects rule commands to be indented with a tab (`\t`).

Command lines preceded by an escaped newline (`\\\n`), as in a command line argument continuation, may omit the tab, or indent arguments with additional tabs.

### Fail

```make
all:
echo "Hello World!"
```

```make
all:
<spaces>echo "Hello World!"
```

```make
all:
<mixed spaces and tabs>echo "Hello World!"
```

### Pass

```make
all:
<tab>echo "Hello World!"
```

### Mitigation

* Configure [EditorConfig](https://editorconfig.org/) and your text editor, to use hard tabs for indentation in makefiles. Reindent the rule declarations. Resave the file.
* Indent `*.go` files with hard tabs as well.
* Other languages are steadily converging on four spaces for indentation, like C, C++, CSS, HTML, Java, JavaScript, Python, Ruby, Rust, shell, ...
* LISP and free-form text files, may not conform to K&R style C indentation. They use variable width indentation, which EditorConfig can model as essentially a form of single space indentation.
* Consider indenting any multiline command arguments an additional tab column deeper than its parent command, for readability.
* Note that Markdown and ebooks sometimes present indentation quirks.
* Consider enabling visible whitespace markers in your text editor.
* When in doubt, consult a hex editor.

## Rule Wholeness

Rule declarations generally require at least one of the following: A prerequisite, an inline command, and/or an indented command.

Rules intentionally set to empty, should generally feature a trailing semicolon (`test:;`).

Ancient makefiles once used a convention of an empty prerequisite, in order to force make to freshly rebuild other targets. However, modern make enjoys the standard `.PHONY` special target for this.

Note that certain special targets are allowed at parse level to be declared with zero prerequisites + zero inline commands + zero indented commands: `.POSIX:`, `.IGNORE:`, `.NOTPARALLEL:`, `.PHONY:`, `.PRECIOUS:`, `.SILENT:`, `.SUFFIXES:`, and `.WAIT:`. They may or may not accept a semicolon inline command, even a blank one.

### Fail

```make
test:
```

```make
DIR: FORCE
	ls DIR

FORCE:
```

### Pass

```make
test: unit-test
```

```make
test:
	echo "Hello World!"
```

```make
test:; echo "Hello World!"
```

```make
test:;
```

```make
# test:
```

```make
<remove extraneous rules>
```

```make
.PHONY: DIR

DIR:
	ls DIR
```

### Mitigation

* Give the rule something useful to do: Introduce at least one prerequisite, indented command, and/or inline command.
* Use `.PHONY` to denote targets that should always be freshly rebuilt.
* Explicitly mark empty rules with reset notation (`<target>:;`)
* Certain special targets may be allowed to be empty. Other special targets may reject the `<target>:;` reset notation.
* Comment out temporarily empty rules
* Remove extraneous rules

## Assignment Operator Portability

Due to incompatible semantics between different make implementations for the `:=` operator, the POSIX standard discourages this operator.

### Fail

```make
M := hello
```

### Pass

```make
M = hello
```

```make
M ::= hello
```

```make
M :::= hello
```

```make
M ?= hello
```

```make
M != echo hello
```

```make
M += hello
```

### Mitigation

* Identify the desired behavior, and apply a corresponding POSIX compliant macro assignment operator.

## Incomplete macro definition

Macro definitions take the form `<name> <assignment operator> [<value>]`.

The first two tokens, `<name>`, and `<assignment operator>` are required. The `<value>` may be omitted, when declaring a blank macro.

### Fail

```make
=
```

```make
=1
```

```make
A
```

(Or the relevant POSIX make assignment operator)

### Pass

```make
A = 1
```

```make
A=
```

(Or the relevant POSIX make assignment operator)

### Mitigation

* Bind a specific macro name to some value.
* Bind a specific macro name to a blank value.

## Include line spaces and quoting

include lines use whitespace to delimit separate file paths. However, POSIX prohibits include lines from using double-quotes (`""`).

### Fail

```make
include "foo.mk"
```

### Pass

```make
include foo.mk
```

### Mitigation

* Remove double quotes from include paths
* Avoid spaces in file and directory names
* Simplify path names

### Special target isolation

When declaring rules with special targets, avoid supplying multiple targets.

Note that `.WAIT` is ignored when specified as a direct target.

### Fail

```make
.SILENT .IGNORE:
```

```make
.SILENT test: unit-test
```

```make
.WAIT test lint: unit-test
```

### Pass

```make
.SILENT:

.IGNORE:
```

```make
.SILENT: unit-test

test: unit-test
```

```make
test: unit-test .WAIT lint
```

### Mitigation

* Limit special targets to once per rule declaration.
* Avoid using the `.WAIT` special target as a direct target. Instead, use `.WAIT` as a prerequisite modifier.

### Multiline expressions

Note that escaped newlines are distinct from newline literals, for example, `\n` in the UNIX command `printf "Hello World!\n"`.

POSIX make presents two distinct semantics for multiline expressions, using escaped newlines (`\\\n`).

The portability risk of multiline *rule commands* is relatively minor. Most make implementations set the `SHELL` macro to a POSIX compatible sh interpreter able to pre-process escaped newlines, even when make itself runs in certain non-POSIX shells.

Note that POSIX prohibits escaped newlines in include lines.

When an escaped newline occurs in a macro definition value, then the escaped newline is replaced with a single space.

When an escaped newline occurs in a rule command, then the escaped newline is preserved and forwarded as a part of the final multiline command to be executed.

A subsequent rule command lines after a preceding escaped newline, is allowed to optionally omit the usual tab indentation. Regardless, a tab in the first column there is not preserved when make generates the final multiline command.

Note that in both cases of multiline macro definitions and multiline rule commands, whitespace sensitivity may lead to subtle processing errors.

Escaped newlines that directly meet the end of the file (`<eof>`), or subsequent lines that don't make sense for the preceding line, may trigger parse errors.

Escaped newlines featuring whitespace between the backslash and the line feed, may trigger parse errors.

Escaped newlines occuring elsewhere in a makefile, may lack a definite parsing behavior. For example, in comments or general macro expressions.

Some escaped newlines occuring in more fringe areas can impair readability: The left side of macro assignment operators, in the opening line of rule declaration blocks, in general macro expressions, and near comments.

We encourage makefile authors to generally limit use of multiline makefile instructions to rule commands, where they can help to tidy up commands with long lists of arguments.

### Fail

```make
include \
foo.mk
```

```make
NAMES \
= Alice\
Bob\
Charlie
```

```make
provision \
:
	pip install \
		bashate \
		safety
```

### Pass

```make
include foo.mk
```

```make
NAMES = Alice Bob Charlie
```

```make
NAMES = Alice\
Bob\
Charlie
```

```make
provision :
	pip install bashate safety
```

```make
provision :
	pip install \
		bashate \
		safety
```

```make
provision :
	pip install -r requirements-dev.txt
```

### Mitigation

* Configure [EditorConfig](https://editorconfig.org/) to remove most trailing whitespace.
* Avoid use of multiline instructions in makefiles in the left side of macro assignment operators, in the opening line of rule declaration blocks, in general macro expressions, and near comments.
* Handle whitespace carefully.
* Handle multiline termination carefully.
* Consider using multilines for complex macro definitions, complex commands, or commands expected to grow longer over time.
* When possible, track build-time packages with a package manager-specific configuration file.
* Consider moving complex rule logic to a separate makefile, script, or compiled application.
* For classic Windows environments, acquire make from [WSL](https://learn.microsoft.com/en-us/windows/wsl/install), [Chocolatey](https://chocolatey.org/), etc., which provide POSIX compatible interpreters.
* For vintage environments like MS-DOS, FreeDOS, or OS/2 Warp, move complex rule commands to a dedicated script.

## make implementation extensions

Implementation-specific syntax may trigger parse errors. For example, syntax specific to GNU make or BSD make.

### Fail

```make
.for i in 1 2 3
test-double-${i}:
	@echo "2 * ${i}" | bc
.endfor
```

### Mitigation

* Consider moving complex logic to a separate makefile, script, or compiled application.
* For clarity, consider renaming GNU-specific makefiles to `GNUmakefile`