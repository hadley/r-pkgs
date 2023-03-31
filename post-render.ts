// The root book file
const rootFile = "_book/book-asciidoc/R-Packages--2e-.adoc";

// List of `lines` to replace in final file
const excludeFromFinal = [
  "[appendix]",
  "include::R-CMD-check.adoc[]"
];

// Read and replace
let contents = Deno.readTextFileSync(rootFile);
excludeFromFinal.forEach((exclude) => {
  contents = contents.replace(`${exclude}\n`, "");
})

// Write updated file
Deno.writeTextFileSync(rootFile, contents);
