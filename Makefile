README.bbcode: README.md pandoc-bbcode-phpbb.lua
	pandoc -f markdown_github-hard_line_breaks+footnotes -t pandoc-bbcode-phpbb.lua -o $@ --smart $<

.PHONY: clean
clean:
	rm -f README.bbcode
