module armos.math.quaternion;
import armos.math;
import std.math;
class Quaternion(T){
	alias Quaternion!(T) ThisType;
	armos.math.Vector!(T, 4) vec;
	
	this(T x, T y, T z, T w){
		vec = new armos.math.Vector!(T, 4);
		this[0] = x;
		this[1] = y;
		this[2] = z;
		this[3] = w;
	}
	this(){
		vec = new armos.math.Vector!(T, 4);
	}
	
	this(armos.math.Vector!(T, 3) axis, T angle){
		vec = new armos.math.Vector!(T, 4);
		this[0] = axis[0]*sin(angle);
		this[1] = axis[1]*sin(angle);
		this[2] = axis[2]*sin(angle);
		this[3] = cos(angle);
	}
	
	const T opIndex(in int index){
		return vec[index];
	}
	
	ref  T opIndex(in int index){
		return vec[index];
	}

	const ThisType opMul(in ThisType r_quat){
		auto v_l = new armos.math.Vector!(T, 3);
		v_l[0] = this[0];
		v_l[1] = this[1];
		v_l[2] = this[2];
		T s_l = this[3];
		
		auto v_r = new armos.math.Vector!(T, 3);
		v_r[0] = r_quat[0];
		v_r[1] = r_quat[1];
		v_r[2] = r_quat[2];
		T s_r = r_quat[3];
		
		auto return_vec = s_l*v_r + s_r*v_r + v_l.vectorProduct(v_r) ;
		auto return_quaternion = new ThisType;
		return_quaternion[0] = return_vec[0];
		return_quaternion[1] = return_vec[1];
		return_quaternion[2] = return_vec[2];
		return_quaternion[3] = s_l*s_r - v_l.dotProduct(v_r);
		return return_quaternion;
	}
	
	const ThisType opNeg(){
		return new ThisType(-this[0], -this[1], -this[2], -this[3]);
	}
		
	const ThisType opAdd(in ThisType q){
		return cast(ThisType)vec + q;
	}
	
	const ThisType opMul(in T r){
		return cast(ThisType)vec*r;
	}
	
	const ThisType opDiv(in T r){
		return cast(ThisType)vec/r;
	}
	
	const T norm(){
		return sqrt(this[0]^^2.0 + this[1]^^2.0 + this[2]^^2.0 + this[3]^^2.0);
	}
	
	const ThisType conjugate(){
		return new ThisType(-this[0], -this[1], -this[2], this[3]);
	}
	
	const ThisType inverse(){
		return conjugate/(norm^^2.0);
	}
		
	const armos.math.Vector!(T, 3) rotatedVector(armos.math.Vector!(T, 3) vec){
		if( norm^^2.0 < T.epsilon){
			return vec;
		}else{
			auto temp_quat = new ThisType(vec[0], vec[1], vec[2], 0);
			auto return_quat= this*temp_quat*this.inverse;
			auto return_vector = new armos.math.Vector!(T, 3)(return_quat[0], return_quat[1], return_quat[2]);
			return return_vector;
		}
	}
	
	void slerp( float t, in ThisType from, in ThisType to){
		double omega, cos_omega, sin_omega, scale_from, scale_to;
		
		ThisType quatTo = cast(ThisType)to;
		cos_omega = from.vec.dotProduct(to.vec);
		
		if (cos_omega < cast(T)0.0) {
			cos_omega = -cos_omega;
			quatTo = -to;
		}
		
		if( (cast(T)1.0 - cos_omega) > T.epsilon ){
			omega = acos(cos_omega);
			sin_omega = sin(omega);
			scale_from = sin(( cast(T)1.0 - t ) * omega) / sin_omega;
			scale_to = sin(t * omega) / sin_omega;
		}else{
			scale_from = cast(T)1.0 - t;
			scale_to = t;
		}
		
		this = ( from * scale_from ) + ( quatTo * scale_to  );
	}
}

alias Quaternion!(float) Quaternionf;
alias Quaternion!(double) Quaterniond;