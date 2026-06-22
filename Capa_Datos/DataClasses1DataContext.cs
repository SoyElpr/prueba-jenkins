using System;
using System.Collections.Generic;
using System.Data.Linq;
using System.Linq;
using System.Linq.Expressions;
using System.Reflection;
using MongoDB.Driver;

namespace Capa_Datos
{
    public class DataClasses1DataContext : IDisposable
    {
        private readonly IMongoDatabase _database;
        private readonly List<Action> _pendingInserts = new List<Action>();
        private readonly List<Action> _pendingDeletes = new List<Action>();
        private readonly Dictionary<string, Dictionary<int, IEntity>> _trackedEntities = new Dictionary<string, Dictionary<int, IEntity>>();

        public DataClasses1DataContext(string connectionString)
        {
            string uri = connectionString;
            if (string.IsNullOrEmpty(uri) || 
                (!uri.StartsWith("mongodb://", StringComparison.OrdinalIgnoreCase) &&
                 !uri.StartsWith("mongodb+srv://", StringComparison.OrdinalIgnoreCase)))
            {
                uri = "mongodb://localhost:27017/Monolito4am";
            }

            var url = new MongoUrl(uri);
            var client = new MongoClient(url);
            _database = client.GetDatabase(url.DatabaseName ?? "Monolito4am");
        }

        public Binary Encriptacon(string plainText)
        {
            byte[] bytes = EncryptionHelper.Encrypt(plainText);
            return new Binary(bytes);
        }

        public string Desencriptacon(Binary cipherBinary)
        {
            if (cipherBinary == null) return string.Empty;
            return EncryptionHelper.Decrypt(cipherBinary.ToArray());
        }

        public MongoTable<Tbl_usuario> Tbl_usuario => new MongoTable<Tbl_usuario>(_database.GetCollection<Tbl_usuario>("tbl_usuario"), this);
        public MongoTable<Tbl_tipo_usuario> Tbl_tipo_usuario => new MongoTable<Tbl_tipo_usuario>("tbl_tipo_usuario", _database.GetCollection<Tbl_tipo_usuario>("tbl_tipo_usuario"), this);
        public MongoTable<Tbl_producto> Tbl_producto => new MongoTable<Tbl_producto>("tbl_producto", _database.GetCollection<Tbl_producto>("tbl_producto"), this);
        public MongoTable<Tbl_provedor> Tbl_provedor => new MongoTable<Tbl_provedor>("tbl_provedor", _database.GetCollection<Tbl_provedor>("tbl_provedor"), this);
        public MongoTable<Tbl_foto_usuario> Tbl_foto_usuario => new MongoTable<Tbl_foto_usuario>("tbl_foto_usuario", _database.GetCollection<Tbl_foto_usuario>("tbl_foto_usuario"), this);
        public MongoTable<Tbl_puntuacion> Tbl_puntuacion => new MongoTable<Tbl_puntuacion>("tbl_puntuacion", _database.GetCollection<Tbl_puntuacion>("tbl_puntuacion"), this);
        public MongoTable<Tbl_auditoria> Tbl_auditoria => new MongoTable<Tbl_auditoria>("tbl_auditoria", _database.GetCollection<Tbl_auditoria>("tbl_auditoria"), this);

        public void TrackInsert<T>(IMongoCollection<T> collection, T entity) where T : class, IEntity
        {
            _pendingInserts.Add(() =>
            {
                string collName = collection.CollectionNamespace.CollectionName;
                entity.Id = GetNextId<T>(collName);
                collection.InsertOne(entity);
            });
        }

        public void TrackDelete<T>(IMongoCollection<T> collection, T entity) where T : class, IEntity
        {
            _pendingDeletes.Add(() =>
            {
                collection.DeleteOne(Builders<T>.Filter.Eq("_id", entity.Id));
            });
        }

        public void TrackEntity<T>(T entity, string collectionName) where T : class, IEntity
        {
            if (entity == null) return;
            if (!_trackedEntities.ContainsKey(collectionName))
            {
                _trackedEntities[collectionName] = new Dictionary<int, IEntity>();
            }
            _trackedEntities[collectionName][entity.Id] = entity;
        }

        public int GetNextId<T>(string collectionName) where T : class, IEntity
        {
            var collection = _database.GetCollection<T>(collectionName);
            var highest = collection.Find(Builders<T>.Filter.Empty)
                                    .Sort(Builders<T>.Sort.Descending("_id"))
                                    .Limit(1)
                                    .FirstOrDefault();
            return highest == null ? 1 : highest.Id + 1;
        }

        public void SubmitChanges()
        {
            // Execute Deletes
            foreach (var action in _pendingDeletes)
            {
                action();
            }
            _pendingDeletes.Clear();

            // Execute Inserts
            foreach (var action in _pendingInserts)
            {
                action();
            }
            _pendingInserts.Clear();

            // Execute Updates
            foreach (var group in _trackedEntities)
            {
                string collName = group.Key;
                var map = group.Value;
                if (map.Count == 0) continue;

                foreach (var kvp in map)
                {
                    int id = kvp.Key;
                    IEntity entity = kvp.Value;

                    var type = entity.GetType();
                    var method = typeof(DataClasses1DataContext)
                        .GetMethod(nameof(ReplaceDocument), BindingFlags.NonPublic | BindingFlags.Instance)
                        .MakeGenericMethod(type);
                    method.Invoke(this, new object[] { collName, id, entity });
                }
            }
        }

        private void ReplaceDocument<T>(string collectionName, int id, T entity) where T : class, IEntity
        {
            var collection = _database.GetCollection<T>(collectionName);
            collection.ReplaceOne(Builders<T>.Filter.Eq("_id", id), entity, new ReplaceOptions { IsUpsert = true });
        }

        public void Dispose()
        {
        }
    }

    public class MongoTable<T> : IQueryable<T> where T : class, IEntity
    {
        private readonly IMongoCollection<T> _collection;
        private readonly DataClasses1DataContext _context;
        private readonly string _collectionName;

        public MongoTable(IMongoCollection<T> collection, DataClasses1DataContext context)
            : this(collection.CollectionNamespace.CollectionName, collection, context)
        {
        }

        public MongoTable(string collectionName, IMongoCollection<T> collection, DataClasses1DataContext context)
        {
            _collection = collection;
            _context = context;
            _collectionName = collectionName;
        }

        public void InsertOnSubmit(T entity)
        {
            _context.TrackInsert(_collection, entity);
        }

        public void DeleteOnSubmit(T entity)
        {
            _context.TrackDelete(_collection, entity);
        }

        private IQueryable<T> Queryable => _collection.AsQueryable();

        public Expression Expression => Queryable.Expression;
        public Type ElementType => Queryable.ElementType;
        public IQueryProvider Provider => Queryable.Provider;

        public IEnumerator<T> GetEnumerator()
        {
            foreach (var item in Queryable)
            {
                _context.TrackEntity(item, _collectionName);
                yield return item;
            }
        }

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator()
        {
            return GetEnumerator();
        }
    }
}
