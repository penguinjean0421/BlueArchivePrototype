using UnityEngine;
using System.Data;
using Mono.Data.Sqlite;
public class DataBaseLoad : MonoBehaviour
{
  void Start()
  {
    string dbName = "/Test/Test.db";
    string connectionString = "URI=file:" + Application.streamingAssetsPath + dbName;
    IDbConnection dbConnection = new SqliteConnection(connectionString);
    dbConnection.Open();

    string tableName = "Test";

    IDbCommand dbCommand = dbConnection.CreateCommand();
    dbCommand.CommandText = "SELECT * FROM " + tableName;
    IDataReader dataReader = dbCommand.ExecuteReader();

    while (dataReader.Read())
    {
      string name = dataReader.GetString(1);
      int age = dataReader.GetInt32(2);
      string group = dataReader.GetString(3);
      Debug.Log("Name : " + name + ", Age : " + age + ", group : " + group);
    }

    dataReader.Close();
  }
}