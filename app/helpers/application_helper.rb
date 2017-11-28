module ApplicationHelper
  def current_top_path?(path)
    tpath = path.split('/').fetch(1, '').sub(/\?.*/, '')
    cpath = url_for(request.params).split('/').fetch(1, '').sub(/\?.*/, '')
    tpath == cpath
  end

  def input_file(input, *args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    options.update(style: 'display: none;')
    file_id = options.fetch(:id)
    filename_id = "#{file_id}_name"
    update = options.delete(:update)

    input_html = input.call(*args, **options)

    if input_html['<div class="field_with_errors">']
      field_with_errors = true
      input_html.sub!('<div class="field_with_errors">', '').sub!('</div>', '')
    else
      field_with_errors = false
    end

    elements = <<-HTML
      <div class="input-group">
        <label class="input-group-btn">
          <span class="btn btn-default">
            Browse&hellip; #{input_html}
          </span>
        </label>
        <input id="#{filename_id}" type="text" class="form-control" readonly>
      </div>
      <script type="text/javascript">
        $('##{file_id}').change(function() {
          var file = $(this);
          var label = file.val().replace(/\\\\/g, '/').replace(/.*\\//, '');
          var filename = $('##{filename_id}');
          filename.val(label);
          #{update ? "$('#{update}').val(label.replace(/\\.[^.]*$/, ''));" : ''}
        });
      </script>
    HTML

    if field_with_errors
      elements = '<div class="field_with_errors">' + elements + '</div>'
    end

    raw(elements)
  end

  def json_editor(data, id: 'json-editor', readonly: false, name: nil)
    content_for(:header) do
      javascript_include_tag 'https://cdnjs.cloudflare.com/ajax/libs/ace/1.2.9/ace.js', cache: 'cached_all'
    end

    if name
      hidden_field_script = <<-JAVASCRIPT
        $('##{id}').closest('form').submit(function() {
          var editor = ace.edit("#{id}");
          $('##{id}-input').val(editor.getValue());
        });
      JAVASCRIPT
    else
      hidden_field_script = ''
    end


    raw <<-HTML
      <div id="#{id}">#{h data}</div>
      #{name ? %!<input id="#{id}-input" name="#{name}" type="hidden">! : ''}
      <script type="text/javascript">
        var editor = ace.edit("#{id}");
        editor.getSession().setMode("ace/mode/json");
        #{readonly ? 'editor.setReadOnly(true);' : ''}
        #{hidden_field_script}
      </script>
    HTML
  end

  def ndjson_editor(data, readonly: false)
    content_for(:header) do
      javascript_include_tag 'https://cdnjs.cloudflare.com/ajax/libs/ace/1.2.9/ace.js', cache: 'cached_all'
    end

    raw <<-HTML
      <div id="ndjson-editor">#{h data}</div>
      <script type="text/javascript">
        var editor = ace.edit("ndjson-editor");
        editor.getSession().setUseWorker(false)
        editor.getSession().setMode("ace/mode/json");
        #{readonly ? 'editor.setReadOnly(true);' : ''}
      </script>
    HTML
  end
end
