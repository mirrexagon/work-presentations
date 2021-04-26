# Deno
- Run `rm -r ~/.cache/deno`

## Intro
- Deno is a JavaScript runtime by the original creator of NodeJS, which aims to improve over Node's design and implementation in some key areas, and take advantage of modern JS features like promises.
    - He has a talk about this, which I posted in the SRG General channel.
- Deno is a single binary application.
* Run `deno --help`

- I haven't used Deno very much yet, but I really like what I've seen of it so far.


## Hello World
* CLEAR TERMINAL

- The main way you'd probably use Deno is creating and running scripts.
* Create a `hello.js` with a function, `deno run hello.js`

```javascript
// hello.js
function print(s) {
    console.log(s);
}

print("Hello, World!");
print(1);
```

- But they can also be fetched via URL.
* Run example from website: `deno run https://deno.land/std/examples/welcome.ts`
- You may notice that is a `.ts` file - Deno supports TypeScript (superset of JavaScript with static typing) out of the box.
    - So we can rename `hello.js` to `hello.ts` and it will be run as TypeScript - demo by adding types to print function (string arg) and calling with number.
    - The number will fail the typecheck.

```javascript
// hello.ts
function print(s: string): void {
    console.log(s);
}

print("Hello, World!");
print(1);
```


## More complex examples
* CLEAR TERMINAL

- Let's try something a bit more complex. Let's make a script that lists all the files and directories in the current directory (and below, if we had any).
* Make `tree.ts`.

- Deno has a builtin runtime API for various operations like file manipulation and networking. These are under the `Deno` namespace, eg. `Deno.mkdir` to create a directory, `Deno.connect` to connect to a host via TCP or UDP.
- It also has a standard library which builds helpful abstractions on top of that lower-level API.
    - It's not currently included with Deno, instead it is available as a module that you can import.

- This gives me the opportunity to show how Deno handles dependencies.
- Using Node, you had to install dependencies via NPM, they get listed in `package.json`, and each project generally has its own `node_modules` folder.
- But in Deno, like we could run a script from a URL earlier, you import dependencies via URLs directly in scripts.

* Import `walk` from std (no version pinning).
* Run the script with just this line. See how it downloads the dependency.
- If we run again, it doesn't redownload the dependency - it is cached globally.

```javascript
// tree.ts
import { walk } from "https://deno.land/std/fs/walk.ts"
```

- As the output tells us, that URL always points to the latest version of std, but the deno.land server also allows us to get specific versions, pinning the dependency.
* Add `@0.84.0` to the URL.
* Run again, it doesn't redownload because we already have that version.

```javascript
// tree.ts
import { walk } from "https://deno.land/std@0.84.0/fs/walk.ts"
```

- There is a service on deno.land called deno.land/x, which is Deno's module repository where users can upload their own modules for others to use.

- Let's finish `tree.ts`.
* Write rest of `tree.ts`.

```javascript
// tree.ts
import { walk } from "https://deno.land/std@0.84.0/fs/walk.ts"

for await (const entry of walk(".")) {
    console.log(entry.path);
}
```

* Try to run, can't because we didn't supply `--allow-read`.
- The idea here is that Deno is secure by default, you have to explicitly give permission to do things like read/write the filesystem or use the network.
* Run again with `--allow-read`.

## What Deno is useful for
- One of Deno's goals is to be good for general scripting where you would normally write a Python or Bash script.
- With a rich standard library and third-party modules and builtin support for async I/O (like Node but completely promised-based), you can do a lot with Deno.
- The URL-based dependency system means you can write a completely-self-contained script as a single file that still can pull in third-party modules.

## What Deno is not useful for
- Deno is a standalone runtime, not an embeddable scripting language - but you could always embed V8. JavaScript as scripting language in IMP when?
- Currently no support for creating a GUI, though people are thinking about how to do it.
- As part of the security design goals, you can't bind arbitrary C APIs to Deno's runtime environment - you can only use what Deno gives you (mostly filesystem and network access).

## Real world example of use
- I found out about Deno while looking for a static site generator. I found one called Lume, which runs on top of Deno.
- Again, because Deno can import scripts and modules from URLs, we can run Lume without needing to download it. Deno will fetch it for us.
* Run `deno run --unstable --allow-all https://deno.land/x/lume/cli.js --help`
- It uses some unstable APIs within Deno, hence why `--unstable`.

## Conclusion
* Run `:info https://deno.land` to make the cat say it.
- Find out more about Deno at `https://deno.land`!
