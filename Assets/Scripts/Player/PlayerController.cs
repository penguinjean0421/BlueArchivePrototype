using System;
using UnityEngine;
public class PlayerController : MonoBehaviour
{
  [Header("Player Move")]
  public float speed = 0f;
  public float maxSpeed = 0f;

  Rigidbody playerRigid = null;
  Transform playerTrans = null;
  void Awake()
  {
    playerRigid = GetComponent<Rigidbody>();
    playerTrans = GetComponent<Transform>();
  }

  void Update()
  {
    if (Input.GetButtonUp("Horizontal"))
    {
      playerRigid.linearVelocity = new Vector3(playerRigid.linearVelocity.normalized.x * 0.5f, playerRigid.linearVelocity.y, playerRigid.linearVelocity.z);
    }

    if (Input.GetButtonUp("Vertical"))
    {
      playerRigid.linearVelocity = new Vector3(playerRigid.linearVelocity.x, playerRigid.linearVelocity.y, playerRigid.linearVelocity.normalized.z * 0.5f);
    }
  }

  void FixedUpdate()
  {
    playerRigid.AddForce(Vector3.right * Input.GetAxisRaw("Horizontal") * speed, ForceMode.Impulse);
    playerRigid.AddForce(Vector3.forward * Input.GetAxisRaw("Vertical") * speed, ForceMode.Impulse);

    if (playerRigid.linearVelocity.z > maxSpeed)
    {
      playerRigid.linearVelocity = new Vector3(playerRigid.linearVelocity.x, playerRigid.linearVelocity.y, maxSpeed);
    }
    else if (playerRigid.linearVelocity.z < -maxSpeed)
    {
      playerRigid.linearVelocity = new Vector3(playerRigid.linearVelocity.x, playerRigid.linearVelocity.y, -maxSpeed);
    }

    if (playerRigid.linearVelocity.x > maxSpeed)
    {
      playerRigid.linearVelocity = new Vector3(maxSpeed, playerRigid.linearVelocity.y, playerRigid.linearVelocity.z);
    }
    else if (playerRigid.linearVelocity.x < -maxSpeed)
    {
      playerRigid.linearVelocity = new Vector3(-maxSpeed, playerRigid.linearVelocity.y, playerRigid.linearVelocity.z);
    }

    if (Input.GetButtonDown("Horizontal"))
    {
      Debug.Log("속도 : " + playerRigid.linearVelocity.x);
    }
    else if (Input.GetButtonDown("Vertical"))
    {
      Debug.Log("속도 " + playerRigid.linearVelocity.z);
    }
  }
}