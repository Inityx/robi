require 'nokogiri'
require 'fileutils'

module Rindle
  class Compiler
    HTML = 'index.html'
    METADATA = 'metadata.opf'
    STYLE = 'stylesheet.css'

    def initialize(dest_dir, stylesheet)
      @dest_dir = dest_dir
      @stylesheet = stylesheet
    end

    def compile(title, posts)
      puts '  Building HTML...'
      html = build_html(title, posts)

      puts '  Building metadata...'
      metadata = build_metadata(title)

      puts '  Assembling files...'
      assemble(metadata, html)

      "#{@dest_dir}/#{METADATA}"
    end

    def build_html(title, posts)
      Nokogiri::HTML::Builder.new(encoding: 'utf-8') { |doc|
        doc.html {
          doc.head {
            doc.title { doc.text title }
            doc.link(
              rel: 'stylesheet',
              href: STYLE,
              type: 'text/css'
            )
          }
          doc.body {
            doc.div(id: 'titlepage') {
              doc.h1 { doc.text title }
              doc.h2 {
                unit = simple_plural('post', posts.size)
                doc.text "#{posts.size} #{unit}"
              }
            }
            doc.div(id: 'tableofcontents') {
              doc.h1 { doc.text 'Posts' }
              doc.ol {
                posts.each do |post|
                  doc.li {
                    doc.a(href: "\##{post.uid}") {
                      doc.text post.title
                    }
                  }
                end
              }
            }
            doc.div(id: 'postwrapper') {
              posts.each do |post|
                doc.div(class: 'post', id: post.uid) {
                  doc.h1 { doc.text post.title }
                  doc.h2 { doc.text "by #{post.author}" }
                  doc.p {
                    body = Nokogiri::HTML::DocumentFragment.parse(post.body)
                    doc << body.content
                  }
                }
              end
            }
          }
        }
      }.to_html
    end

    def build_metadata(title)
      Nokogiri::XML::Builder.new { |xml|
        xml.root {
          xml.product {
            # TODO: fix metadata with namespaces
            xml.manifest {
              xml.item(
                :id => 'text',
                :'media-type' => 'text/x-oeb1-document',
                :href => "#{HTML}#postwrapper"
              )
            }
            xml.spine  { # TODO: ToC
              xml.itemref(idref: 'text')
            }
            xml.guide {
              xml.reference(type: 'text', title: title, href: HTML)
            }
          }
        }
      }.to_xml
    end

    def assemble(metadata, html)
      Dir.mkdir(@dest_dir) unless Dir.exist?(@dest_dir)
      File.open("#{@dest_dir}/#{HTML}", 'w') { |file| file.write(html) }
      File.open("#{@dest_dir}/#{METADATA}",  'w') { |file| file.write(metadata) }
      FileUtils.cp(@stylesheet, "#{@dest_dir}/#{STYLE}")
    end

    def convert
    end

    def simple_plural(word, count)
      if count.abs > 1
        "#{word}s"
      else
        word
      end
    end
  end
end
