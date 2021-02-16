# Generate Mermaid

This tool implements the [mermaid-cli](https://github.com/mermaidjs/mermaid.cli) to generate an SVG from a [mermaid](https://github.com/mermaid-js/mermaid) document.

## Setup

1. Install dependencies

   ```
   npm install
   ```

## Usage

1. Copy the mermaid (.mmd) file to the input folder.

2. Run the generate script.

   ```
   npm run generate
   ```

3. Check that it worked: a new file named `output.svg` should appear in the `output/` directory. Open it in your browser to view.

## Future Work

| Task               | Description                                                                                                                 |
| ------------------ | --------------------------------------------------------------------------------------------------------------------------- |
| Dynamic file names | Generate output files based on the name of input files. This will prevent tool from overwriting previously generated files. |
| Dynamic paths      | Make the tool usable to accept any input path, or even better be usable from any location and be pipe-able.                 |
