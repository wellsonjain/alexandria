require 'rails_helper'

RSpec.describe 'Books', type: :request do

  let(:ruby_microscope) { create(:ruby_microscope) }
  let(:rails_tutorial) { create(:ruby_on_rails_tutorial) }
  let(:agile_web_dev) { create(:agile_web_development) }

  let(:books) { [ruby_microscope, rails_tutorial, agile_web_dev] }

  describe 'GET /api/books' do
    before { books }

    context 'default behavior' do
      before { get '/api/books'}

      it 'gets HTTP status code 200' do
        expect(response.status).to eq 200
      end

      it 'receives a json with the "data" root key' do
        expect(json_body['data']).to_not be_nil
      end

      it 'receive all 3 books' do
        expect(json_body['data'].size).to eq 3
      end
    end

    context 'field picking' do
      context 'with the fields paramter' do
        before { get '/api/books?fields=id,title,author_id' }

        it 'gets books with only id, title, and author_id' do
          json_body['data'].each do |book|
            expect(book.keys).to eq ['id', 'title', 'author_id']
          end
        end
      end

      context 'without the field parameter' do
        before { get '/api/books' }

        it 'gets books with all the fields specified in the presenter' do
          json_body['data'].each do |book|
            expect(book.keys).to eq BookPresenter.build_attributes.map(&:to_s)
          end
        end
      end
    end

    context 'pagination' do
      context 'when asking for the first page' do
        before { get('/api/books?page=1&per=2') }

        it 'receives HTTP status 200' do
          expect(response.status).to eq 200
        end

        it 'receives only two books' do
          expect(json_body['data'].size).to eq 2
        end

        it 'receives a response with the Link header' do
          expect(response.headers['Link'].split(', ').first).to eq(
            '<http://www.example.com/api/books?page=2&per=2>; rel="next"'
          )
        end
      end

      context 'when asking for the second page' do
        before { get('/api/books?page=2&per=2') }

        it 'receives HTTP status 200' do
          expect(response.status).to eq 200
        end

        it 'receives only one books' do
          expect(json_body['data'].size).to eq 1
        end
      end
    end

    context 'sorting' do
      context 'with valid column name "id"' do
        it 'sorts the books by "id desc"' do
          get('/api/books?sort=id&dir=desc')
          expect(json_body['data'].first['id']).to eq agile_web_dev.id
          expect(json_body['data'].last['id']).to eq ruby_microscope.id
        end
      end

      context 'with invalid column name "fid"' do
        before { get '/api/books?sort=fid&dir=asc' }

        it 'gets "400 Bad Request" back' do
          expect(response.status).to eq 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not be nil
        end

        it 'receives "sort=fid" as an invalid param' do
          expect(json_body['error']['invalid_params']).to eq 'sort=fid'
        end
      end
    end

    context 'filtering' do
      context 'with valid filtering param "q[title_cont]=Microscope"' do
        it 'receives "Ruby under a microscope" back' do
           get('/api/books?q[title_cont]=Microscope')
           expect(json_body['data'].first['id']).to eq ruby_microscope.id
           expect(json_body['data'].size).to eq 1
        end
      end

      context 'with invalid filtering param "q[ftitle_cont]=Microscope"' do
        before { get('/api/books?q[ftitle_cont]=Ruby') }

        it 'gets "400 Bad Request" back' do
           expect(response.status).to eq 400
        end

        it 'receives an error' do
           expect(json_body['error']).to_not be nil
        end

        it 'receives "q[ftitle_cont]=Ruby" as an invalid param' do
           expect(json_body['error']['invalid_params']).to eq 'q[ftitle_cont]=Ruby'
        end
      end
    end
  end
end
