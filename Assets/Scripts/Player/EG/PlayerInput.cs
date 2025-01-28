using UnityEngine;

public class PlayerInput : MonoBehaviour
{
    [Header("Weapon Equip/Unequip")]
    public bool EKey = false;
    public float weaponEquipCoolTime = 0.5f;
    private float weaponEquipCurTime = 0.0f;

    [Header("Run")]
    public bool Run = false;

    [Header("BasicAttack")]
    public bool basicAttack = false;
    public float basicAttackCoolTime = 0.2f;
    private float basicAttackCurTime = 0.0f;

    private void Start()
    {
        weaponEquipCurTime = weaponEquipCoolTime;
        basicAttackCurTime = basicAttackCoolTime;
    }

    private void Update()
    {
        InputE();
        Running();
        BasicAttack();
    }

    private void InputE()
    {
        if (weaponEquipCurTime < weaponEquipCoolTime)
        {
            weaponEquipCurTime += Time.deltaTime;
        }
        if (Input.GetKeyDown("e") && EKey == false && weaponEquipCurTime >= weaponEquipCoolTime)
        {
            EKey = true;
            weaponEquipCurTime = 0.0f;
        }
        else if (Input.GetKeyDown("e") && EKey == true && weaponEquipCurTime >= weaponEquipCoolTime)
        {
            EKey = false;
            weaponEquipCurTime = 0.0f;
        }
    }

    private void Running()
    {
        if (Input.GetKeyDown(KeyCode.LeftShift) && Run == false)
        {
            Run = true;
        }
        else if (Input.GetKeyDown(KeyCode.LeftShift) && Run == true)
        {
            Run = false;
        }
    }

    private void BasicAttack()
    {
        if (basicAttackCurTime < basicAttackCoolTime)
        {
            basicAttackCurTime += Time.deltaTime;
        }
        if (Input.GetMouseButtonDown(0) && basicAttack == false && basicAttackCurTime >= basicAttackCoolTime && EKey == true)
        {
            basicAttack = true;
            basicAttackCurTime = 0.0f;
        }
        
        if (basicAttackCurTime >= basicAttackCoolTime)
        {
            basicAttack = false;
        }
    }
}
