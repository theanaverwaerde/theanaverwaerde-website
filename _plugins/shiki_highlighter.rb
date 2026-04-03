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
    const { codeToHtml } = require('shiki');

    async function run() {
      try {
        const html = await codeToHtml(#{code.to_json}, {
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
