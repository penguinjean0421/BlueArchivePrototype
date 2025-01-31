using UnityEngine;
using System.Data;
using Mono.Data.Sqlite;
public class DataBaseWrite : MonoBehaviour
{
  void Start()
  {
    string dbName = "/Test/test.db";
    string connectionString = "URI=file:" + Application.streamingAssetsPath + dbName;
    IDbConnection dbConnection = new SqliteConnection(connectionString);
    dbConnection.Open();

    int no = 1;
    string name = "서수진";
    int age = 27;
    string group = "솔로";
    string insertQuery = $"INSERT INTO Test (No, 이름, 나이, 소속그룹) VALUES ({no}, '{name}', {age}, '{group}')";

    IDbCommand dbCommand = dbConnection.CreateCommand();
    dbCommand.CommandText = insertQuery;
    dbCommand.ExecuteNonQuery();
    dbCommand.Dispose();
    dbConnection.Close();
  }
}
