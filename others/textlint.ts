import { createLinter, loadLinterFormatter, loadTextlintrc } from "npm:textlint";
//import _ from "npm:textlint-rule-";
import _ from "npm:textlint-rule-preset-ja-technical-writing";
import _ from "npm:textlint-rule-preset-jtf-style";
// import _ from "npm:textlint-rule-preset-ja-engineering-paper";
import _ from "npm:textlint-plugin-latex2e";

const descriptor = await loadTextlintrc();
const linter = createLinter({descriptor});
const results = await linter.lintFiles(Deno.args);

const formatter = await loadLinterFormatter({formatterName: "unix"});
const output = formatter.format(results);
console.log(output);

