# Sample sequel migration,

Sequel.migration do
  up do
    # Create albums_artists table
    create_table(:objects) do
      # foreign_key :album_id, :albums
      # foreign_key :artist_id, :artists
      index [:album_id, :artist_id], :unique=>true
    end

    # Insert one row in the albums_artists table
    # for each row in the albums table where there
    # is an associated artist
    self[:albums_artists].insert([:album_id, :artist_id],
     self[:albums].select(:id, :artist_id).exclude(:artist_id=>nil))

    # Drop the now unnecesssary column from the albums table
    drop_column :albums, :artist_id
  end
  down do
    # Add the foreign key column back to the artists table
    alter_table(:albums){add_foreign_key :artist_id, :artists}

    # If possible, associate each album with one of the artists
    # it was associated with.  This loses information, but
    # there's no way around that.
    self[:albums_artists].
     group(:album_id).
     select{[album_id, max(artist_id).as(artist_id)]}.
     having{artist_id >  0}.
     all do |r|
       self[:artists].
        filter(:id=>r[:album_id]).
        update(:artist_id=>r[:artist_id])
     end

    # Drop the albums_artists table
    drop_table(:albums_artists)
  end
end