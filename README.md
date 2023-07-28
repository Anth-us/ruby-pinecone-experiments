Some simple experiments with using OpenAI embeddings and Pinecone to implement long-term memory for AI agents.

The way it works:

1. Use the [OpenAI embeddings API](https://platform.openai.com/docs/guides/embeddings) to
    1. [compute vector embeddings](https://github.com/endymion/ruby-pinecone-experiments/blob/main/pinecone.rb#L52) for each chunk of text you want to be able to search for.
2. Then, store them in [Pinecone.io](https://www.pinecone.io/)
    1. along with [metadata](https://github.com/endymion/ruby-pinecone-experiments/blob/main/pinecone.rb#L39-L41) that you’ll need for finding that chunk of text if it turns up in a query result
3. To query for the most-appropriate memories in that vector index for a given new chunk of text,
    1. [compute the embeddings](https://github.com/endymion/ruby-pinecone-experiments/blob/main/pinecone.rb#L59) for that new text in the same way,
    2. and [query the Pinecone index](https://github.com/endymion/ruby-pinecone-experiments/blob/main/pinecone.rb#L58) for that embedding.

```
[3] pry(main)> memory.query_vector_database(text:"The baseball went right over the fence!")
=> {"results"=>[],
 "matches"=>
  [{"id"=>"4", "score"=>0.737516463, "values"=>[], "metadata"=>{"url"=>"https://example.com/sports"}},
   {"id"=>"1", "score"=>0.721562207, "values"=>[], "metadata"=>{"url"=>"https://example.com/astronomy"}},
   {"id"=>"5", "score"=>0.678328514, "values"=>[], "metadata"=>{"url"=>"https://example.com/history"}},
   {"id"=>"2", "score"=>0.67092222, "values"=>[], "metadata"=>{"url"=>"https://example.com/culinary"}},
   {"id"=>"3", "score"=>0.667715669, "values"=>[], "metadata"=>{"url"=>"https://example.com/business"}}],
 "namespace"=>""}
[4] pry(main)> memory.query_vector_database(text:"Some boring financial stuff.")
=> {"results"=>[],
 "matches"=>
  [{"id"=>"3", "score"=>0.781698227, "values"=>[], "metadata"=>{"url"=>"https://example.com/business"}},
   {"id"=>"1", "score"=>0.737261176, "values"=>[], "metadata"=>{"url"=>"https://example.com/astronomy"}},
   {"id"=>"4", "score"=>0.720855892, "values"=>[], "metadata"=>{"url"=>"https://example.com/sports"}},
   {"id"=>"5", "score"=>0.705321372, "values"=>[], "metadata"=>{"url"=>"https://example.com/history"}},
   {"id"=>"2", "score"=>0.685572565, "values"=>[], "metadata"=>{"url"=>"https://example.com/culinary"}}],
 "namespace"=>""}
[5] pry(main)> memory.query_vector_database(text:"I'm going to cook dinner now.")
=> {"results"=>[],
 "matches"=>
  [{"id"=>"2", "score"=>0.750419259, "values"=>[], "metadata"=>{"url"=>"https://example.com/culinary"}},
   {"id"=>"1", "score"=>0.705064118, "values"=>[], "metadata"=>{"url"=>"https://example.com/astronomy"}},
   {"id"=>"4", "score"=>0.682778716, "values"=>[], "metadata"=>{"url"=>"https://example.com/sports"}},
   {"id"=>"3", "score"=>0.666097879, "values"=>[], "metadata"=>{"url"=>"https://example.com/business"}},
   {"id"=>"5", "score"=>0.662973, "values"=>[], "metadata"=>{"url"=>"https://example.com/history"}}],
 "namespace"=>""}
 ``````