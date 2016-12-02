require 'nokogiri'
require 'fileutils'

module Rindle
  class Compiler
    def initialize(dest_dir, stylesheet_source)
      @dest_dir = dest_dir

      @html_file = 'index.html'
      @stylesheet_source = stylesheet_source
      @stylesheet_file = File.basename(@stylesheet_source)
      @table_of_contents_file = 'tableofcontents.ncx'
      @metadata_file = 'metadata.opf'
    end

    def compile(title, posts)
      puts '  Building HTML...'
      html = build_html(title, posts)

      puts '  Building metadata...'
      metadata = build_metadata(title)

      puts '  Building Table of Contents...'
      table_of_contents = build_table_of_contents(title, posts)

      puts '  Assembling files...'
      assemble(metadata, html, table_of_contents)

      "#{@dest_dir}/#{@metadata_file}"
    end

    def build_html(title, posts)
      Nokogiri::HTML::Builder.new(encoding: 'utf-8') { |doc|
        doc.html {
          doc.head {
            doc.title { doc.text title }
            doc.link(
              rel: 'stylesheet',
              href: @stylesheet_file,
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
                    doc.a(href: "##{post.uid}") {
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
                  doc.div {
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
          xml.package(
            :'unique-identifier' => title,
            :'xmlns:opf' => 'http://www.idpf.org/2007/opf',
            :'xmlns:asd' => 'http://www.idpf.org/asdfaf'
          ) {
            xml.metadata {
              xml.send(
                :'dc-metadata',
                :'xmlns:dc' => 'http://purl.org/metadata/dublin_core',
                :'xmlns:oebpackage' => 'http://openebook.org/namespaces/oeb-package/1.0/'
              ) {
                xml.send(:'dc:Title', title)
                xml.send(:'dc:Language', 'en')
                xml.send(:'dc:Creator', 'Reddit')
                xml.send(:'x-metadata')
              }
            }
            xml.manifest {
              # xml.item(
              #   :id => 'content',
              #   :'media-type' => 'text/x-oeb1-document',
              #   :href => "#{HTML}#tableofcontents"
              # )
              xml.item(
                :id => 'ncx',
                :'media-type' => 'application/x-dtbncx+xml',
                :href => @table_of_contents_file
              )
              xml.item(
                :id => 'text',
                :'media-type' => 'text/x-oeb1-document',
                :href => "#{@html_file}"
              )
            }
            xml.spine(toc: 'ncx')  {
              # xml.itemref(idref: 'content')
              xml.itemref(idref: 'text')
            }
            xml.guide {
              xml.reference(type: 'toc', title: 'Table of Contents', href: @table_of_contents_file)
              xml.reference(type: 'text', title: title, href: @html_file)
            }
          }
        }
      }.to_xml
    end

    def build_table_of_contents(title, posts)
      Nokogiri::XML::Builder.new { |xml|
        xml.doc.create_internal_subset(
          'ncx',
          '-//NISO//DTD ncx 2005-1//EN',
          'http://www.daisy.org/z3986/2005/ncx-2005-1.dtd'
        )
        xml.ncx(xmlns: 'http://www.daisy.org/z3986/2005/ncx/', version: '2005-1') {
          xml.docTitle {
            xml.text_ title
          }
          xml.navMap {
            # xml.navPoint(id: 'toc', playOrder: 1) {
            #   xml.navLabel {
            #     xml.text_ 'Table of Contents'
            #   }
            #   xml.content(src: @html_file)
            # }
            posts.zip(1..Float::INFINITY).each do |post, index|
              xml.navPoint(id: post.uid, playOrder: index) {
                xml.navLabel {
                  xml.text_ post.title
                }
                xml.content(src: "#{@html_file}##{post.uid}")
              }
            end
          }
        }
      }.to_xml
    end

    def assemble(metadata, html, table_of_contents)
      Dir.mkdir(@dest_dir) unless Dir.exist?(@dest_dir)

      File.open("#{@dest_dir}/#{@html_file}", 'w') { |file| file.write(html) }
      File.open("#{@dest_dir}/#{@metadata_file}",  'w') { |file| file.write(metadata) }
      File.open("#{@dest_dir}/#{@table_of_contents_file}",  'w') { |file| file.write(table_of_contents) }

      FileUtils.cp(@stylesheet_source, "#{@dest_dir}/#{@stylesheet_file}")
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
