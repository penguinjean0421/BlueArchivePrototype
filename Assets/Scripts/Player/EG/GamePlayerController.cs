using UnityEngine;

using UnityEngine.UI;

public class GamePlayerController : MonoBehaviour
{
    [Header("References")]
    public Transform orientation;
    public Transform player;
    public Transform playerOBJ;
    public Rigidbody rb;
    public Animator animController;
    public PlayerInput playerInputSC;
    public GameObject weapon;
    public Text textBullet;

    [Header("PlayerSetting")]
    public float walkSpeed = 0;
    public float runSpeed = 0;
    public float rotationSpeed = 0;
    public float rbDrag = 3;

    [Header("SkillSetting")]
    public int bulletCount = 6;
    public int curBulletCount = 0;

    // private vairables
    float horizontalInput = 0.0f;
    float verticalInput = 0.0f;
    private Vector3 moveDir = Vector3.zero;
    private float curSpeed = 0.0f;
    private bool canAttack = true;

    // weapon equip/unequip smooth blend
    float smoothBlend = 0.0f;

    private void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;

        curSpeed = walkSpeed;

        curBulletCount = bulletCount;
    }

    private void Update()
    {
        GetInput();
        PlayerRotate();
        WeaponEquip();
        BasicAttack(); 
        Reroading();
        CheckBullet();
    }

    private void FixedUpdate()
    {
        PlayerMovement();
    }

    private void GetInput()
    {
        horizontalInput = Input.GetAxis("Horizontal");
        verticalInput = Input.GetAxis("Vertical");
    }

    private void PlayerRotate()
    {
        // rotate orientation
        Vector3 viewDir = player.position - new Vector3(transform.position.x, player.position.y, transform.position.z);
        orientation.forward = viewDir.normalized;

        // rotate player object
        Vector3 inputDir = orientation.forward * verticalInput + orientation.right * horizontalInput;

        if (inputDir != Vector3.zero)
        {
            // player OBJ rotate
            playerOBJ.forward = Vector3.Slerp(playerOBJ.forward, inputDir.normalized, Time.deltaTime * rotationSpeed);
        }
    }

    private void PlayerMovement()
    {
        moveDir = orientation.forward * verticalInput + orientation.right * horizontalInput;
        rb.AddForce(moveDir.normalized * curSpeed * 10.0f, ForceMode.Force);
        rb.linearDamping = rbDrag;

        if (horizontalInput != 0 || verticalInput != 0)
        {
            animController.SetBool("IsWalk", true);
        }
        else if (horizontalInput == 0 && verticalInput == 0)
        {
            animController.SetBool("IsWalk", false);
            animController.SetBool("IsRun", false);
            playerInputSC.Run = false;
        }

        if (playerInputSC.Run == true)
        {
            curSpeed = runSpeed;
            animController.SetBool("IsRun", true);
            animController.SetBool("IsWalk", false);
        }
        else if (playerInputSC.Run == false)
        {
            curSpeed = walkSpeed;
            animController.SetBool("IsRun", false);
        }

        if (playerInputSC.basicAttack == true && canAttack == true)
        {
            curSpeed = 0.0f;
        }
        else if (playerInputSC.basicAttack == false && playerInputSC.Run == false)
        {
            curSpeed = walkSpeed;
        }
        else if (playerInputSC.basicAttack == false && playerInputSC.Run == true)
        {
            curSpeed = runSpeed;
        }
    }

    private void WeaponEquip()
    {
        if (playerInputSC.EKey == true)
        {
            if (smoothBlend < 1.0f)
            {
                smoothBlend += Time.deltaTime * 3;
                weapon.GetComponent<Renderer>().material.SetFloat("_EmissivePower", smoothBlend);
            }
        }
        else
        {
            if (smoothBlend > 0)
            {
                smoothBlend -= Time.deltaTime * 3;
                if (smoothBlend < 0)
                {
                    smoothBlend = 0.0f;
                }
                weapon.GetComponent<Renderer>().material.SetFloat("_EmissivePower", smoothBlend);
            }
        }
    }

    private void BasicAttack()
    {
        if (playerInputSC.basicAttack == true && canAttack == true)
        {
            animController.SetBool("Attacking", true);
        }
        else
        {
            animController.SetBool("Attacking", false);
        }
    }

    private void Reroading()
    {
        if (curBulletCount == 0)
        {
            weapon.GetComponent<Renderer>().material.SetFloat("_GradientRange", 1);
            canAttack = false;
        }
        else
        {
            weapon.GetComponent<Renderer>().material.SetFloat("_GradientRange", 0);
            canAttack = true;
        }
        
        if (Input.GetKeyDown("r"))
        {
            curBulletCount = bulletCount;
        }
    }

    private void CheckBullet()
    {
        textBullet.text = curBulletCount.ToString();
    }
}
