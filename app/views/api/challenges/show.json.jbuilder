# frozen_string_literal: true

json.(@challenge, :title, :content)
json.checks @challenge.checks, :id, :stdin, :stdout
json.mode @challenge.category.editor_mode

json.archivement @challenge.has_archivement?(current_user)

json.previous do
  if record = @challenge.previous
    json.title record.title
    json.url category_challenge_path(@challenge.category, record)
  end
end

json.next do
  if record = @challenge.next
    json.title record.title
    json.url category_challenge_path(@challenge.category, record)
  end
end
