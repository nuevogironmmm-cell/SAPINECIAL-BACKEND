# -*- coding: utf-8 -*-
"""
Script to run Phase 1 security tests
"""
import sys
import os

def main():
    """Run Phase 1 security tests"""
    print("?? EJECUTANDO PRUEBAS DE SEGURIDAD - FASE 1")
    print("=" * 60)
    print("Mejoras implementadas:")
    print("? Variables de entorno centralizadas")
    print("? Sistema de autenticaci?n JWT mejorado")
    print("? Configuraci?n CORS restrictiva")
    print("? Pruebas unitarias b?sicas")
    print("=" * 60)
    
    try:
        # Importar y ejecutar pruebas
        from test_basic import run_basic_tests
        
        success = run_basic_tests()
        
        if success:
            print("\n?? TODAS LAS PRUEBAS PASARON")
            print("?? FASE 1 COMPLETADA EXITOSAMENTE")
            print("\n?? Mejoras de seguridad implementadas:")
            print("  • Variables de entorno configuradas")
            print("  • Autenticaci?n JWT robusta")
            print("  • CORS configurado correctamente")
            print("  • Pruebas b?sicas funcionando")
            print("\n??  Recomendaciones para producci?n:")
            print("  • Crear archivo .env con valores reales")
            print("  • Cambiar JWT_SECRET_KEY en producci?n")
            print("  • Configurar ALLOWED_ORIGINS espec?ficos")
            print("  • Considerar base de datos para escalabilidad")
            
            return 0
        else:
            print("\n? ALGUNAS PRUEBAS FALLARON")
            print("?? Revisar los errores anteriores")
            return 1
            
    except ImportError as e:
        print(f"\n?? Error importando m?dulos: {e}")
        print("?? Aseg?rate de instalar dependencias:")
        print("  pip install -r requirements.txt")
        return 1
        
    except Exception as e:
        print(f"\n?? Error ejecutando pruebas: {e}")
        return 1

if __name__ == "__main__":
    sys.exit(main())