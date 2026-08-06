require 'open3'

Jekyll::Hooks.register :posts, :pre_render do |post|

  regex = /```(\w+)\n(.*?)\n\s*```/m

  post.content.gsub!(regex) do
    lang = Regexp.last_match(1)
    code = Regexp.last_match(2)

    highlight_code(code, lang)
  end
end

def highlight_code(code, lang)
  js_script = <<~JS
    const { createHighlighter } = require('shiki');
    const yaml = require('js-yaml');

    async function run() {
      try {
        let highlighter;

        if ('#{lang}' == 'rpy')
        {
          const url = "https://raw.githubusercontent.com/renpy/vscode-language-renpy/refs/heads/master/syntaxes/renpy.tmLanguage.yaml";
          const res = await fetch(url);
          if (!res.ok) {
            throw new Error(`Failed to fetch grammar: ${res.statusText}`);
          }

          const yamlText = await res.text();
          const json = JSON.parse(JSON.stringify(yaml.load(yamlText), null, 2), 'utf8');

          highlighter = await createHighlighter({
            langs: [json],
            langAlias: {
                rpy: "Ren'Py",
                rpym: "Ren'Py",
              },
            themes: ['github-light', 'github-dark'],
          });
        }
        else {
          highlighter = await createHighlighter({
            langs: ['#{lang}'],
            themes: ['github-light', 'github-dark'],
          });
        }

        const html = await highlighter.codeToHtml(#{code.to_json}, {
          lang: '#{lang}',
          themes: {
            light: 'github-light',
            dark: 'github-dark',
          },
          transformers: [
            {
              pre(node) {
                this.addClassToHast(node, 'language-#{lang}')
              }
            }
          ]
        });

        process.stdout.write(html);
        process.exit(0);
      } catch (err) {
        process.stderr.write(err.message);
        process.exit(1);
      }
    }

    run();
  JS

  stdout, stderr, status = Open3.capture3('node', stdin_data: js_script)

  raise "Shiki Error: #{stderr}" unless status.success?

  stdout
end
