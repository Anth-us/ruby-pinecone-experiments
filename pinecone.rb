require 'pry'
require "dotenv/load"
require 'openai'
require 'pinecone'

class Memory
  attr_reader :openai_client, :pinecone_client, :pinecone_index

  def initialize
    OpenAI.configure   do |config|
      config.access_token = ENV.fetch('OPENAI_API_KEY')
    end
    @openai_client        = OpenAI::Client.new
  
    Pinecone.configure do |config|
      config.api_key      = ENV.fetch('PINECONE_API_KEY')
      config.environment  = ENV.fetch('PINECONE_INDEX_ENVIRONMENT')
    end
    @pinecone_client      = Pinecone::Client.new
    @pinecone_index       = @pinecone_client.index(
                              ENV.fetch('PINECONE_INDEX_NAME')
                            )
  end

  def compute_embeddings_for_string(string:)
    @openai_client.embeddings(
        parameters: {
            model: "text-embedding-ada-002",
            input: string
        }
    ).dig("data", 0, "embedding")
  end

  def upsert_embeddings_to_vector_database(
    id:, url:, embeddings:)
    @pinecone_index.upsert(
      vectors: [{
        id: id.to_s,
        metadata: {
          url: url
        },
        values: embeddings
      }]
    )
  end

  def process_memories(memories:)
    memories.each do |memory|
      upsert_embeddings_to_vector_database(
        id: memory[:id],
        url: memory[:url],
        embeddings: compute_embeddings_for_string(string:memory[:text])
      )
    end
  end

  def query_vector_database(text:)
    @pinecone_index.query(
      vector: compute_embeddings_for_string(string:text))
  end

end

memories = [
  {
    id: 1,
    url: 'https://example.com/astronomy',
    text: <<~STRING,
      Staring at the night sky, one could not help but be awestruck by the expanse of the universe. Stars twinkling in the distance, some of them no longer existing, yet their light still reaches us after billions of years. Planets like Mars and Venus can be seen at certain times of the year, offering a glimpse into our celestial neighbors. Black holes, supernovae, galaxies, and cosmic dust form a complex tapestry of existence, both frightening and fascinating.
    STRING
  },
  {
    id: 2,
    url: 'https://example.com/culinary',
    text: <<-STRING
      The art of French cooking is a meticulous process, encapsulating hundreds of years of culinary expertise. The base for many dishes is a delicately prepared 'mirepoix,' a mixture of diced carrots, celery, and onions. Duck Confit, Boeuf Bourguignon, and Coq au Vin, each with their unique flavors, transport you straight to the heart of France. With a glass of Burgundy wine, the experience becomes sublime.
    STRING
  },
  {
    id: 3,
    url: 'https://example.com/business',
    text: <<-STRING
      Investing in the stock market requires a solid understanding of financial markets and economic trends. Companies like Amazon, Google, and Microsoft lead in technology-driven growth, while traditional industries like oil and manufacturing continue to provide steady returns. From blue-chip stocks to high-risk high-reward startups, the portfolio can vary greatly. However, the golden rule remains - diversify your investments to mitigate risks.
    STRING
  },
  {
    id: 4,
    url: 'https://example.com/sports',
    text: <<-STRING
      Soccer, or football as it's known outside the US, is a global phenomenon uniting people from all walks of life. The FIFA World Cup, held every four years, showcases the best talent from around the globe. Teams like Brazil, Germany, and Argentina have historic rivalries, fueling a spectacle of skill, strategy, and sometimes, sheer luck. Whether it's Lionel Messi's precision or Cristiano Ronaldo's athleticism, the sport is a theatre of dreams.
    STRING
  },
  {
    id: 5,
    url: 'https://example.com/history',
    text: <<-STRING
      The ancient civilization of Egypt, dating back to 3100 BC, fascinates historians and archeologists alike. From the majestic pyramids of Giza to the mysterious Sphinx, these relics of a bygone era speak of an advanced society skilled in engineering and astronomy. Pharaohs like Tutankhamun and Cleopatra have become iconic figures. Hieroglyphics, mummies, and intricate burial rituals give us a glimpse into their beliefs about life, death, and the afterlife.
    STRING
  }  
]

memory = Memory.new
memory.process_memories(memories:memories)

binding.pry