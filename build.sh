#!/usr/bin/env bash
# exit on error
set -o errexit

pip install -r requirements.txt

python -c "from narciss import create_app, db; app = create_app(); app.app_context().push(); db.create_all()"

# إنشاء الأدوار الأساسية والمستخدم الإداري
python -c "
from narciss import create_app, db
from narciss.models import Role, User
from flask_bcrypt import Bcrypt

app = create_app()
with app.app_context():
    # التحقق من وجود الأدوار
    if Role.query.count() == 0:
        admin_role = Role(name='admin', description='مدير النظام')
        supplier_role = Role(name='supplier', description='مورد / مصنع')
        distributor_role = Role(name='distributor', description='تاجر / موزع')
        individual_role = Role(name='individual', description='مشتري فردي')
        shipping_role = Role(name='shipping', description='شركة شحن')
        
        db.session.add(admin_role)
        db.session.add(supplier_role)
        db.session.add(distributor_role)
        db.session.add(individual_role)
        db.session.add(shipping_role)
        db.session.commit()
        
        # إنشاء حساب مدير
        bcrypt = Bcrypt()
        hashed_password = bcrypt.generate_password_hash('admin123').decode('utf-8')
        admin_user = User(username='admin', email='admin@example.com', password=hashed_password, verified=True)
        admin_user.roles.append(admin_role)
        db.session.add(admin_user)
        db.session.commit()
        print('تم إنشاء الأدوار والمستخدم الإداري بنجاح')
    else:
        print('الأدوار موجودة بالفعل')
"
