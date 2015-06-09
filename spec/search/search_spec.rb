# need to include Jane Eyre fixtures
unless ENV['TRAVIS']
  describe 'Jane Eyre Relevancy' do
    it 'The novel is first in a keyword search' do
      jane_eyre_novel_id = "1317967"
      resp = solr_resp_doc_ids_only({'q'=>'Jane Eyre'})
      resp.should include(jane_eyre_novel_id).as_first_result
    end

    it 'Appears before book about Jane Eyre' do
      book_about_id = "323739"
      jane_eyre_novel_id = "1317967"
      resp = solr_resp_doc_ids_only({'q'=>'Jane Eyre'})
      resp.should include(jane_eyre_novel_id).before(book_about_id)
    end
  end
end